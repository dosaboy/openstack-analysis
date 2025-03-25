#!/bin/bash -eu
#
# Description: capture number rabbitmq missed heartbeats
#
. $SCRIPT_ROOT/lib.sh

MODULE=oslo.messaging._drivers.impl_rabbit
. $SCRIPT_ROOT/log_expressions.sh

# override - no project ids to check
get_categories ()
{
    echo "-"
}

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
y_label=missed-rabbitmq-heartbeats
expr1=""
expr2="s/$EXPR_LOG_DATE_GROUP_TIME [0-9]+ \w+ $MODULE \[.+\] A recoverable connection\/channel error occurred, trying to reconnect: Too many heartbeats missed/\1/p"

process_log_aggr $(filter_log $LOG $MODULE) $data_tmp $csv_path "$expr1" "$expr2"
write_meta $results_dir time $y_label
cleanup $data_tmp $csv_path
