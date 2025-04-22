#!/bin/bash -eu
#
# Description: ovn sb db leader switch for snapshot
#

# NOTE: only run this for sb logs
LOG_NAME_FILTER=ovsdb-server-sb.log
LOG_MODULE='\|raft\|'
Y_LABEL=ovn-ovsdb-sb-snapshot-leader-switches
PLOT_TYPE=stackplot

main ()
{
    row_expr='^[0-9-]+T([0-9:]+)\.[0-9]+Z.+\|raft\|INFO\|Transferring leadership to write a snapshot.'
    process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true $Y_LABEL
}
