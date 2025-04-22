#!/bin/bash -eu
#
# Description: capture time taken to allocate network resources for new vm.
#

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=nova.network.neutron
Y_LABEL=net-info-cache-update-time

main ()
{
    seq_start_expr="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT_GROUP_REQ $EXPR_LOG_INSTANCE_UUID allocate_for_instance\(\) allocate_for_instance .+"
    seq_end_expr="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT_GROUP_REQ $EXPR_LOG_INSTANCE_UUID Updating instance_info_cache with network_info:.+"
    filtered=$(filter_log $LOG "$LOG_MODULE")
    # filter out updates done by the compute servive itself
    filtered=$(filter_log $filtered "(\- - - - -\])|\[-\]" true)
    process_log_deltas $filtered $DATA_TMP $CSV_PATH "$seq_start_expr" "$seq_end_expr" false
}
