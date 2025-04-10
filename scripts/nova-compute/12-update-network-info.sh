#!/bin/bash -eu
#
# Description: capture time taken to update network info cache for new vm.
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for nova-compute logs
[[ $LOG =~ nova-compute.log ]] || exit 0

SCRIPT_HEADER nova.network.neutron

col_expr="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT_GROUP_REQ $EXPR_LOG_INSTANCE_UUID Building network info cache for instance _get_instance_nw_info.+"
row_expr="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT_GROUP_REQ $EXPR_LOG_INSTANCE_UUID Updating instance_info_cache with network_info:.+"
filtered=$(filter_log $LOG "$LOG_MODULE")
# filter out updates done by the compute servive itself
filtered=$(filter_log $filtered "(\- - - - -\])|\[-\]" true)
process_log_deltas $filtered $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" false

SCRIPT_FOOTER net-info-cache-update-time
