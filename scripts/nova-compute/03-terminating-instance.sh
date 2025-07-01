# Description: capture number of instance delete requests.

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=nova.compute.manager
Y_LABEL=num-instance-deletes
PLOT_TYPE=bar_stacked

main ()
{
    col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT_GROUP_USER .+ Terminating instance"
    row_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT_INSERT_USER .+ Terminating instance"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 0 true
}
