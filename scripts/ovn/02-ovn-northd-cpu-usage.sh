#!/bin/bash -eu
#
# Description: capture api http return codes
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER '\|poll_loop\|'

expr1='s/^[0-9-]+T[0-9:]+\.[0-9]+Z.+\|poll_loop\|INFO\|.+ \([0-9.]+:[0-9]+<->[0-9.]+:([0-9]+)\) .+ \([0-9]+% CPU usage\)/\1/p'
# NOTE: we use group 2 as the value to override the default tally
expr2='s/^[0-9-]+T([0-9:]+)\.[0-9]+Z.+\|poll_loop\|INFO\|.+ \([0-9.]+:[0-9]+<->[0-9.]+:$INSERT\) .+ \(([0-9]+)% CPU usage\)/\1 \2/p'
y_label=ovn-northd-cpu-usage
process_log_aggr $LOG $DATA_TMP $CSV_PATH "$expr1" "$expr2" true

SCRIPT_FOOTER $y_label
