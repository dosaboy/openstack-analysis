#!/bin/bash -eu
BIN_ROOT=$(dirname $(readlink --canonicalize $0))
export SCRIPT_ROOT=$BIN_ROOT/../scripts
. $SCRIPT_ROOT/lib/env.sh

[[ -n $SOS_ROOT ]] || { echo "ERROR: sos root required (--path)"; exit 1; }

declare -A ENTRYPOINTS=(
    [octavia]=/var/log/octavia/octavia-worker${LOGROTATE:-.log.1}
    [ovs.0]=/var/log/openvswitch/ovsdb-server${LOGROTATE:-.log.1.gz}
    [ovs.1]=/var/log/openvswitch/ovs-vswitchd${LOGROTATE:-.log.1.gz}
    [ovn-central.0]=/var/log/ovn/ovsdb-server-nb${LOGROTATE:-.log.1.gz}
    [ovn-central.1]=/var/log/ovn/ovsdb-server-sb${LOGROTATE:-.log.1.gz}
    [ovn-central.2]=/var/log/ovn/ovn-northd${LOGROTATE:-.log.1.gz}
    [neutron-api.0]=/var/log/neutron/neutron-server${LOGROTATE:-.log.1.gz}
    [neutron-api.1]=/var/log/apache2/other_vhosts_access${LOGROTATE:-.log.1}
    [nova-compute]=/var/log/nova/nova-compute${LOGROTATE:-.log.1}
    [nova-api]=/var/log/nova/nova-conductor${LOGROTATE:-.log.1}
    [rabbitmq-server]=/var/log/rabbitmq/rabbit@*${LOGROTATE:-.log.1}
)

mkdir -p $OUTPUT_PATH
export JOBS_DEFS_DIR=$(mktemp -d --suffix -job-defs)
for sos in $(ls -d $SOS_ROOT); do
    if [[ -n $HOST_OVERRIDE ]]; then
        echo $sos| grep -q $HOST_OVERRIDE || continue
    fi
    export ROOT=$sos
    if [[ -r $ROOT/hostname ]]; then
        export HOSTNAME=$(cat $ROOT/hostname)
    else
        export HOSTNAME="unknownhost-$(uuidgen)"
        echo "WARNING: could not determine hostname in $ROOT - using $HOSTNAME"
    fi

    for agent in ${!ENTRYPOINTS[@]}; do
        if [[ -n $AGENT_SCRIPTS ]] && [[ $AGENT_SCRIPTS != $agent ]]; then
            echo "INFO: skipping $agent scripts"
            continue
        fi
        export AGENT_NAME=${agent%.*}
        # If matches more then one file take the first
        export LOG=$(ls $ROOT${ENTRYPOINTS[$agent]} 2>/dev/null| head -n1)
        [[ -n $LOG ]] || continue
        if [[ ${LOG::1} != / ]]; then
            LOG="$(pwd)/$LOG"
        fi
        [[ -e $LOG ]] && $SCRIPT_ROOT/$AGENT_NAME/__all__.sh
    done
done

[[ -d $JOBS_DEFS_DIR ]] || { echo "ERROR: jobs path not found"; exit 1; }
PIDS=()
for job in $(find $JOBS_DEFS_DIR -name run.sh); do
    $job &
    PIDS+=( $! )
    (( ${#PIDS[@]} % MAX_CONCURRENT_JOBS == 0 )) && { echo waiting; wait; }
done
wait
rm -rf $JOBS_DEFS_DIR

$PLOT_GRAPHS || exit 0
$BIN_ROOT/plot.sh --host "$HOST_OVERRIDE"
