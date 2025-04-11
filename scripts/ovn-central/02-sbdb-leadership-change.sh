#!/bin/bash -eu
#
# Description: ovn sb db leader switch for snapshot
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for sb logs
[[ $LOG =~ ovsdb-server-sb.log ]] || exit 0

SCRIPT_HEADER '\|raft\|'

row_expr='s/^[0-9-]+T([0-9:]+)\.[0-9]+Z.+\|raft\|INFO\|Transferring leadership to write a snapshot./\1/p'
y_label=ovn-ovsdb-sb-snapshot-leader-switches
process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true $y_label

SCRIPT_FOOTER $y_label
