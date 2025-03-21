#!/bin/bash -eu
export SCRIPT_ROOT=$(dirname $(readlink --canonicalize $0))
. $SCRIPT_ROOT/env.sh

[[ -n $SOS_ROOT ]] || { echo "ERROR: sos root required (--path)"; exit 1; }

for sos in $(ls -d $SOS_ROOT); do
    if [[ -n $HOST_OVERRIDE ]]; then
        echo $sos| grep -q $HOST_OVERRIDE || continue
    fi
    export ROOT=$sos
    export HOSTNAME=$(cat $ROOT/hostname)

    export LOG=$ROOT/var/log/nova/nova-compute.log
    [[ -e $LOG ]] && $SCRIPT_ROOT/nova-compute/__all__.sh

    export LOG=$ROOT/var/log/neutron/neutron-server.log
    [[ -e $LOG ]] && $SCRIPT_ROOT/neutron-api/__all__.sh

    for f in openvswitch/ovsdb-server.log ovn/ovsdb-server-nb.log ovn/ovsdb-server-sb.log; do
        export LOG=$ROOT/var/log/$f
        [[ -e $LOG ]] && $SCRIPT_ROOT/ovn/__all__.sh
    done

    export LOG=$ROOT/var/log/octavia/octavia-worker.log.3.gz
    [[ -e $LOG ]] && $SCRIPT_ROOT/octavia/__all__.sh
done

$PLOT_GRAPHS || exit 0

echo "Plotting graphs..."
if [[ -n $HOST_OVERRIDE ]]; then
    rm graphs/$HOST_OVERRIDE/*
    find results_data -name \*.csv| grep $HOST_OVERRIDE| \
        xargs -l python3 $SCRIPT_ROOT/../python/plot.py
else
    rm -rf graphs/*
    find results_data -name \*.csv| \
        xargs -l python3 $SCRIPT_ROOT/../python/plot.py
fi

