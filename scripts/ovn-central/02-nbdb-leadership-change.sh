#!/bin/bash -eu
#
# Description: ovn nb db leader switch for snapshot
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for nb logs
[[ $LOG =~ ovsdb-server-nb.log ]] || exit 0

SCRIPT_HEADER '\|raft\|'

row_expr='^[0-9-]+T([0-9:]+)\.[0-9]+Z.+\|raft\|INFO\|Transferring leadership to write a snapshot.'
y_label=ovn-ovsdb-nb-snapshot-leader-switches
process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true $y_label

SCRIPT_FOOTER $y_label
