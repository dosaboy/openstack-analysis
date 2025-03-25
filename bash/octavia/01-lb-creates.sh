#!/bin/bash -eu
#
# Description: loadbalancer creates
#
. $SCRIPT_ROOT/lib.sh

MODULE=octavia.controller.queue.v1.endpoints
. $SCRIPT_ROOT/log_expressions.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
y_label=lb-creates
expr1="s/^$EXPR_LOG_DATE_GROUP_TIME [0-9]+ \w+ $MODULE \[-\] Creating load balancer '\S+'.../\1/p"

process_log_tally $LOG $data_tmp $csv_path "$expr1" $y_label
write_meta $results_dir time $y_label
cleanup $data_tmp $csv_path
