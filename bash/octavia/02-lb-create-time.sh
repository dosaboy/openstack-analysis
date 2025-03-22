#!/bin/bash -eu
#
# Description:
#
. $SCRIPT_ROOT/lib.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv

expr1="^([0-9-]+) ([0-9:]+{3})\.[0-9]+ [0-9]+ .+ \[-\] Creating load balancer '([a-z0-9-]+)'\.+"
expr2='^([0-9-]+) ([0-9:]+{3})\.[0-9]+ [0-9]+ .+ \[(\S+ ?){6}\] Mark ACTIVE in DB for load balancer id: ([a-z0-9-]+)$'
process_log_deltas $LOG $data_tmp $csv_path "$expr1" "$expr2"

write_meta $results_dir time lb-creates
cleanup $data_tmp $csv_path
