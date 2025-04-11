#!/bin/bash -eu
#
# Description: capture time taken to allocate network resources for new vm.
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for nova-compute logs
[[ $LOG =~ nova-compute.log ]] || exit 0

SCRIPT_HEADER os_vif

col_expr="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT_GROUP_REQ Plugging vif .+"
row_expr="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT_GROUP_REQ Successfully plugged vif .+"
process_log_deltas $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" true

SCRIPT_FOOTER os-vif-plug-time
