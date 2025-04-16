#!/bin/bash -eu
#
# Description: ovs bfd state changs
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for ovs-vswitchd logs
[[ $LOG =~ ovs-vswitchd.log ]] || exit 0

SCRIPT_HEADER '\|bfd(\S+)?\|'

row_expr='^[0-9-]+T([0-9:]+)\.[0-9]+Z.+\|bfd(\S+)?\|\S+\|(\S+): BFD state change: (\S+)'
y_label=ovs-bfd-state-change
process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true $y_label

SCRIPT_FOOTER $y_label
