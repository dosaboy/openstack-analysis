#!/bin/bash -eu
#
# Description: capture number rabbitmq missed heartbeats
#
. $SCRIPT_ROOT/lib.sh

# override - no project ids to check
get_categories ()
{
    echo "-"
}

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
module=oslo.messaging._drivers.impl_rabbit
e1=""
e2="s/[0-9-]+ ([0-9:]+:[0-9])[0-9]:[0-9]+.[0-9]+ [0-9]+ \w+ $module \[.+\] A recoverable connection\/channel error occurred, trying to reconnect: Too many heartbeats missed/\10/p"

process_log_aggr $(filter_log $LOG $module) $data_tmp $csv_path "$e1" "$e2"
write_meta $results_dir time missed-rabbitmq-heartbeats
cleanup $data_tmp $csv_path
