#!/bin/bash -eu
#
# Description:
#   Nova will process multiple build requests concurrently. We can get an idea
#   of how busy the service is by looking at how many other requests are
#   processed between the start and end of a single vm request. We call these
#   interrupts the "backlog" and this script extracts the maximum backlog size
#   in every 10 minutes of time.
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for nova-compute logs
[[ $LOG =~ nova-compute.log ]] || exit 0

SCRIPT_HEADER nova.compute.manager

col_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT $EXPR_LOG_INSTANCE_UUID_GROUP_UUID Starting instance\.\.\. _do_build_and_run_instance.*"
row_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT $EXPR_LOG_INSTANCE_UUID_GROUP_UUID Took [0-9.]+ seconds to build instance."
expr3='(Starting instance|Claim successful|VM Started \(Lifecycle Event\).+|Deleted allocations)'
y_label=instance-build-max-backlog-size
process_log_event_deltas $LOG $DATA_TMP $CSV_PATH $y_label "$col_expr" "$row_expr" "$expr3" true

SCRIPT_FOOTER $y_label
