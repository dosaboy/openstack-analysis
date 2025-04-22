#!/bin/bash -eu
#
# Description: capture time taken to allocate network resources for new vm.
#

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=os_vif
Y_LABEL=os-vif-plug-time

main ()
{
    seq_start_expr="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT_GROUP_REQ Plugging vif .+"
    seq_end_expr="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT_GROUP_REQ Successfully plugged vif .+"
    process_log_deltas $LOG $DATA_TMP $CSV_PATH "$seq_start_expr" "$seq_end_expr" true
}
