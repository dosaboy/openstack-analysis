#!/bin/bash -eu
#
# Description:
#
. $SCRIPT_ROOT/lib.sh

MODULE=nova.virt.libvirt.driver
. $SCRIPT_ROOT/log_expressions.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
y_label=network-vif-plugged-timeouts
expr1="s/^$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT $EXPR_LOG_INSTANCE_UUID Timeout waiting for \[\('network-vif-plugged', .+/\1/p"

process_log_tally $LOG $data_tmp $csv_path "$expr1" $y_label
write_meta $results_dir time $y_label
cleanup $data_tmp $csv_path
