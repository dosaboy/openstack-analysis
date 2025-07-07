# Description: capture amount of time nova-compute locks are held for.

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=oslo_concurrency.lockutils
Y_LABEL=max-lock-held-time
PLOT_TYPE=bar_stacked

main ()
{
    col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT Lock \\\"([a-z0-9_-]+)\\\" .+ :: held ([0-9]+).[0-9]+s.+"
    row_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT Lock \\\"\$name\\\" .+ :: held [0-9]+.[0-9]+s.+"
    process_log_max_lock_times $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" true
}
