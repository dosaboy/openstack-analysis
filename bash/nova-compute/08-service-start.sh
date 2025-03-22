#!/bin/bash -eu
#
# Description: capture number of times nova-compute service is restarted.
#
. $SCRIPT_ROOT/lib.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
module=nova.service
e1='s/.+/-/p'
e2="s/[0-9-]+ ([0-9:]+:[0-9])[0-9]:[0-9]+.[0-9]+ [0-9]+ \w+ $module \[-\] Starting compute node .+/\10/p"

process_log_aggr $(filter_log $LOG $module) $data_tmp $csv_path "$e1" "$e2"
write_meta $results_dir time nova-compute-restart
cleanup $data_tmp $csv_path
