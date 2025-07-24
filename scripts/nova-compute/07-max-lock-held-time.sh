# Description: capture amount of time nova-compute locks are held for.

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=oslo_concurrency.lockutils
Y_LABEL=max-lock-held-time
PLOT_TYPE=bar_stacked

main ()
{
    # For the lock owner name we trim the root and first submodule so that the legend is readable.
    # Also cap held times to > 1s
    col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT Lock \\\"\S+\\\" \\\"released\\\" by \\\"[a-z]+\.[a-z]+\.(\S+)\\\" :: held [1-9][0-9]+.[0-9]+s.+"
    row_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT Lock \\\"\S+\\\" \\\"released\\\" by \\\"[a-z]+\.[a-z]+\.\$INSERT\\\" :: held ([1-9][0-9]+).[0-9]+s.+"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 1 true
}
