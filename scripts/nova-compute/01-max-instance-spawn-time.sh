# Description: capture max amount of time taken to spawn instances.

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=nova.compute.manager
Y_LABEL=max-spawn-time
PLOT_TYPE=bar_stacked
PLOT_TITLE="Max Instance Spawn Time"
LEGEND_TITLE="UserID"

main ()
{
    col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT_GROUP_USER .+ Took [0-9.]+ seconds to spawn the instance on the hypervisor."
    row_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT_INSERT_USER .+ Took ([0-9]+).[0-9]+ seconds to spawn the instance on the hypervisor."
    process_log_max $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" true true
}
