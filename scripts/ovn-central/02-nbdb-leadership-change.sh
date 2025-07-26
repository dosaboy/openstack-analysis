# Description: ovn nb db leader switch for snapshot.

# NOTE: only run this for nb logs
LOG_NAME_FILTER=ovsdb-server-nb.log
LOG_MODULE='\|raft\|'
Y_LABEL=ovn-ovsdb-nb-snapshot-leader-switches
PLOT_TYPE=bar_stacked
PLOT_TITLE="Snapshot Leader Switches"

main ()
{
    row_expr='^([0-9-]+)T([0-9:]+)\.[0-9]+Z.+\|raft\|INFO\|Transferring leadership to write a snapshot.'
    process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true $Y_LABEL
}
