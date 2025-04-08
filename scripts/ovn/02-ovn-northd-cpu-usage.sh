#!/bin/bash -eu
#
# Description: capture ovn northd high CPU usage
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for ovn-northd logs
[[ $LOG =~ ovn-northd.log ]] || exit 0

SCRIPT_HEADER '\|poll_loop\|'

expr1='^[0-9-]+T[0-9:]+\.[0-9]+Z.+\|poll_loop\|INFO\|.+ \([0-9.]+:[0-9]+<->[0-9.]+:([0-9]+)\) .+ \([0-9]+% CPU usage\)'
# NOTE: we a second group as the value to override the default tally
expr2='^[0-9-]+T([0-9:]+)\.[0-9]+Z.+\|poll_loop\|INFO\|.+ \([0-9.]+:[0-9]+<->[0-9.]+:$INSERT\) .+ \(([0-9]+)% CPU usage\)'
y_label=ovn-northd-cpu-usage
process_log_aggr2 $LOG $DATA_TMP $CSV_PATH "$expr1" "$expr2" 2 true

SCRIPT_FOOTER $y_label
