# Description: capture number of ovsdbapp transcation queue full errors.

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=ovsdbapp.backend.ovs_idl.command
Y_LABEL=events
PLOT_TYPE=bar_stacked
PLOT_TITLE="OVSDBAPP Transaction Queue Full Errors"

main ()
{
    col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT_GROUP_USER .+ cause: TXN queue is full"
    row_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT_INSERT_USER .+ cause: TXN queue is full"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 0 true
}
