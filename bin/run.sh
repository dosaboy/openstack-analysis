#!/bin/bash -eu
BIN_ROOT=$(dirname $(readlink --canonicalize $0))
export SCRIPT_ROOT=$BIN_ROOT/../scripts
. $SCRIPT_ROOT/lib/env.sh

[[ -n $SOS_ROOT ]] || { echo "ERROR: sos root required (--path)"; exit 1; }

declare -A ENTRYPOINTS=(
    [octavia]=/var/log/octavia/octavia-worker.log$LOGROTATE
    [ovs.0]=/var/log/openvswitch/ovsdb-server.log$LOGROTATE
    [ovs.1]=/var/log/openvswitch/ovs-vswitchd.log$LOGROTATE
    [ovn-central.0]=/var/log/ovn/ovsdb-server-nb.log$LOGROTATE
    [ovn-central.1]=/var/log/ovn/ovsdb-server-sb.log$LOGROTATE
    [ovn-central.2]=/var/log/ovn/ovn-northd.log$LOGROTATE
    [neutron-api.0]=/var/log/neutron/neutron-server.log$LOGROTATE
    [neutron-api.1]=/var/log/apache2/other_vhosts_access.log$LOGROTATE
    [nova-compute]=/var/log/nova/nova-compute.log$LOGROTATE
    [nova-api.0]=/var/log/nova/nova-api-wsgi.log$LOGROTATE
    [nova-api.1]=/var/log/nova/nova-scheduler.log$LOGROTATE
    [nova-api.2]=/var/log/nova/nova-conductor.log$LOGROTATE
    [rabbitmq-server]=/var/log/rabbitmq/rabbit@*.log$LOGROTATE
)

mkdir -p $OUTPUT_PATH
export JOBS_DEFS_DIR=$(mktemp -d --suffix -job-defs)
for sos in $(ls -d $SOS_ROOT); do
    if (( ${#HOST_OVERRIDE[@]} )); then
        echo $sos| egrep -q $(echo ${HOST_OVERRIDE[@]}| tr ' ' '|' ) || continue
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
        for logpath in $ROOT${ENTRYPOINTS[$agent]} $ROOT${ENTRYPOINTS[$agent]}.gz; do
            export LOG=$(ls $ROOT${ENTRYPOINTS[$agent]} 2>/dev/null| head -n1)
            [[ -z $LOG ]] || break
        done
        [[ -n $LOG ]] || continue
        if [[ ${LOG::1} != / ]]; then
            LOG="$(pwd)/$LOG"
        fi
        [[ -e $LOG ]] && $SCRIPT_ROOT/$AGENT_NAME/__all__.sh
    done
done

[[ -d $JOBS_DEFS_DIR ]] || { echo "ERROR: jobs path not found"; exit 1; }
PIDS=()
for hostjobs in $(ls -d $JOBS_DEFS_DIR/*); do
    echo "## running $(basename $hostjobs) jobs"
    for job in $(find $hostjobs -type f); do
        $job &
        PIDS+=( $! )
        (( ${#PIDS[@]} % MAX_CONCURRENT_JOBS == 0 )) && { echo "INFO: waiting for $MAX_CONCURRENT_JOBS job(s) to complete before continuing"; wait; }
    done
done
wait
rm -rf $JOBS_DEFS_DIR

$PLOT_GRAPHS || { echo -e "\nINFO: don't forget to run ./plot.sh (or use --plot) to (re)create graphs from new data."; exit 0; }
$BIN_ROOT/plot.sh ${CLI_OPTS_CACHE[@]}
