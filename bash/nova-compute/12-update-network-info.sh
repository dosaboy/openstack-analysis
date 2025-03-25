#!/bin/bash -eu
#
# Description: capture time taken to update network info cache for new vm.
#
. $SCRIPT_ROOT/lib.sh

MODULE=nova.network.neutron
. $SCRIPT_ROOT/log_expressions.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
y_label=net-info-cache-update-time
expr1="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT_GROUP_REQ $EXPR_LOG_INSTANCE_UUID Building network info cache for instance _get_instance_nw_info.+"
expr2="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT_GROUP_REQ $EXPR_LOG_INSTANCE_UUID Updating instance_info_cache with network_info:.+"
filtered=$(filter_log $LOG "$MODULE")
# filter out updates done by the compute servive itself
filtered=$(filter_log $filtered "(\- - - - -\])|\[-\]" true)

process_log_deltas $filtered $data_tmp $csv_path "$expr1" "$expr2"
write_meta $results_dir time $y_label
cleanup $data_tmp $csv_path
