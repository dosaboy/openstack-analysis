#!/bin/bash -eu
#
# Description:
#
. $SCRIPT_ROOT/lib.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv

module=octavia.controller.queue.v1.endpoints
e1="s/^[0-9-]+ ([0-9:]+{3})\.[0-9]+ [0-9]+ \w+ $module \[-\] Creating load balancer '\S+'.../\1/p"
process_log_tally $LOG $data_tmp $csv_path "$e1" lb-creates

write_meta $results_dir time lb-creates
cleanup $data_tmp $csv_path
