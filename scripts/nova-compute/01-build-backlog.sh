# Description:
#   Nova will process multiple build requests concurrently. We can get an idea
#   of how busy the service is by looking at how many other requests are
#   processed between the start and end of a single vm request. We call these
#   interrupts the "backlog" and this script extracts the maximum backlog size
#   in every 10 minutes of time.

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=nova.compute.manager
Y_LABEL=instance-build-max-backlog-size
PLOT_TYPE=bar_stacked

main ()
{
    seq_start_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT $EXPR_LOG_INSTANCE_UUID_GROUP_UUID Starting instance\.\.\. _do_build_and_run_instance.*"
    seq_end_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT $EXPR_LOG_INSTANCE_UUID_GROUP_UUID Took [0-9.]+ seconds to build instance."
    seq_event_expr='(Starting instance|Claim successful|VM Started \(Lifecycle Event\).+|Deleted allocations)'
    process_log_event_deltas $LOG $DATA_TMP $CSV_PATH "$seq_start_expr" "$seq_end_expr" "$seq_event_expr" true
}
