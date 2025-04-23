# Description: capture number of aborted instance create requests

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=nova.compute.manager
Y_LABEL=aborted-instance-creates
PLOT_TYPE=stackplot

main ()
{
    col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT_GROUP_USER .+ Build of instance [a-z0-9-]+ aborted: .+"
    row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT_INSERT_USER .+ Build of instance [a-z0-9-]+ aborted: .+"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 1 true
}
