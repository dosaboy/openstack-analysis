#!/bin/bash -eu
#
# Description: capture resource tracking for memory usage
#
. $SCRIPT_ROOT/lib.sh

MODULE=nova.compute.resource_tracker
. $SCRIPT_ROOT/log_expressions.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
y_label=memory-mb
expr="s/^$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Final resource view: name=\S+ phys_ram=([0-9]+)MB used_ram=([0-9]+)MB phys_disk=[0-9]+GB used_disk=[0-9]+GB total_vcpus=[0-9]+ used_vcpus=[0-9]+ .+/\1 \2 \3/p"
keys=( phys_ram used_ram )

process_log_simple $(filter_log $LOG $MODULE) $data_tmp $csv_path "$expr" ${keys[@]}
write_meta $results_dir time $y_label
cleanup $data_tmp $csv_path
