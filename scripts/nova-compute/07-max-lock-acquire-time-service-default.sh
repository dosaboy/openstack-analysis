# Description: Capture amount of time nova-compute takes to acquire a lock.
#              This looks specifically at locks taken by the compute service
#              itself i.e the "default" context.

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=oslo_concurrency.lockutils
Y_LABEL=max-lock-acquire-time
PLOT_TYPE=bar_stacked

main ()
{
    # Cap held times to > 1s
    col_expr="$EXPR_LOG_DATE $EXPR_LOG_DEFAULT Lock \\\"\S+\\\" acquired by \\\"(\S+)\\\" :: waited [1-9][0-9]*\.[0-9]+s .+"
    row_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_DEFAULT Lock \\\"\S+\\\" acquired by \\\"\$INSERT\\\" :: waited ([1-9][0-9]*)\.[0-9]+s .+"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 1 true
}
