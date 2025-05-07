# Description: get deltas between waiting for and receviing an external event.

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=nova.compute.manager
Y_LABEL=external-event-req-rsp-max-delta-secs
PLOT_TYPE=bar_stacked

main ()
{
    seq_start_expr="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT $EXPR_LOG_INSTANCE_UUID Preparing to wait for external event ([0-9a-z-]+) .+"
    seq_end_expr="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT $EXPR_LOG_INSTANCE_UUID Received event ([0-9a-z-]+) .+"
    process_log_deltas_multicol $LOG $DATA_TMP $CSV_PATH "$seq_start_expr" "$seq_end_expr" true
}
