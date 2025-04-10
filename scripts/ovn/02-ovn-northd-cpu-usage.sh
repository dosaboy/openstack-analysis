#!/bin/bash -eu
#
# Description: capture ovn northd high CPU usage
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for ovn-northd logs
[[ $LOG =~ ovn-northd.log ]] || exit 0

SCRIPT_HEADER '\|poll_loop\|'

col_expr='^[0-9-]+T[0-9:]+\.[0-9]+Z.+\|poll_loop\|INFO\|.+ \([0-9.]+:[0-9]+<->[0-9.]+:([0-9]+)\) .+ \([0-9]+% CPU usage\)'
# NOTE: we a second group as the value to override the default tally
row_expr='^[0-9-]+T([0-9:]+)\.[0-9]+Z.+\|poll_loop\|INFO\|.+ \([0-9.]+:[0-9]+<->[0-9.]+:$INSERT\) .+ \(([0-9]+)% CPU usage\)'
y_label=ovn-northd-cpu-usage-max
process_log_aggr2 $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 2 true

SCRIPT_FOOTER $y_label
