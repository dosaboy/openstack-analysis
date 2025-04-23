# Description: capture max amount of time taken to build instances.

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=nova.compute.manager
Y_LABEL=max-instance-build-time
PLOT_TYPE=stackplot

main ()
{
    col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT_GROUP_USER .+ Took [0-9.]+ seconds to build instance."
    row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT_INSERT_USER .+ Took ([0-9]+).[0-9]+ seconds to build instance."
    process_log_max $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" true
}
