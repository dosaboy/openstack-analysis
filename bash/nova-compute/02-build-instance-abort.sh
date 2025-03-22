#!/bin/bash -eu
#
# Description: capture number of aborted instance create requests
#
. $SCRIPT_ROOT/lib.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
module=nova.compute.manager
e1="s/[0-9-]+ [0-9:.]+ [0-9]+ \w+ $module \[req-[0-9a-z-]+ [0-9a-z-]+ ([0-9a-z-]+) .+\] .+ Build of instance [a-z0-9-]+ aborted: .+/\1/p"
e2="s/[0-9-]+ ([0-9:]+:[0-9])[0-9]:[0-9]+.[0-9]+ [0-9]+ \w+ $module \[req-[0-9a-z-]+ ([0-9a-z-]+) \$c .+\] .+ Build of instance [a-z0-9-]+ aborted: .+/\10/p"

process_log_aggr $(filter_log $LOG $module) $data_tmp $csv_path "$e1" "$e2"
write_meta $results_dir time aborted-instance-creates
cleanup $data_tmp $csv_path
