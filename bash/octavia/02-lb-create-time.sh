#!/bin/bash -eu
#
# Description:
#
. $SCRIPT_ROOT/lib.sh

MODULE=octavia.controller.queue.v1.endpoints
. $SCRIPT_ROOT/log_expressions.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
y_label=lb-creates
expr1="^$EXPR_LOG_DATE_GROUP_TIME [0-9]+ .+ \[-\] Creating load balancer '([a-z0-9-]+)'\.+"
expr2='^$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Mark ACTIVE in DB for load balancer id: ([a-z0-9-]+)$'

process_log_deltas $LOG $data_tmp $csv_path "$expr1" "$expr2"
write_meta $results_dir time $y_label
cleanup $data_tmp $csv_path
