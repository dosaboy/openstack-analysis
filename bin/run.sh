#!/bin/bash -eu
BIN_ROOT=$(dirname $(readlink --canonicalize $0))
export SCRIPT_ROOT=$BIN_ROOT/../scripts
. $SCRIPT_ROOT/lib/env.sh

[[ -n $SOS_ROOT ]] || { echo "ERROR: sos root required (--path)"; exit 1; }

declare -A ENTRYPOINTS=(
    [octavia]=/var/log/octavia/octavia-worker.log${LOGROTATE}
    [ovn.0]=/var/log/openvswitch/ovsdb-server.log${LOGROTATE}
    [ovn.1]=/var/log/ovn/ovsdb-server-nb.log${LOGROTATE}
    [ovn.2]=/var/log/ovn/ovsdb-server-sb.log${LOGROTATE}
    [neutron-api]=/var/log/neutron/neutron-server.log${LOGROTATE}
    [nova-compute]=/var/log/nova/nova-compute.log${LOGROTATE}
    [nova-api]=/var/log/nova/nova-conductor.log${LOGROTATE}
    [rabbitmq-server]=/var/log/rabbitmq/rabbitmq-server.log${LOGROTATE}
)

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

    for mod in ${!ENTRYPOINTS[@]}; do
        export LOG=$ROOT${ENTRYPOINTS[$mod]}
        [[ -e $LOG ]] && $SCRIPT_ROOT/${mod%.*}/__all__.sh
    done
done

$PLOT_GRAPHS || exit 0
$BIN_ROOT/plot.sh --host "$HOST_OVERRIDE"
