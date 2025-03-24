#!/bin/bash -eu
#
# Description: capture number of ovsdbapp timeouts
#
. $SCRIPT_ROOT/lib.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
module=nova.compute.manager
y_label=ovsdbapp-timeouts
expr1="s/[0-9-]+ [0-9:]+:[0-9][0-9]:[0-9]+.[0-9]+ [0-9]+ \w+ $module .+ ovsdbapp.exceptions.TimeoutException: Commands \[(\w+)\(.+\].+/\1/p"
expr2="s/[0-9-]+ ([0-9:]+{3}).[0-9]+ [0-9]+ \w+ $module .+ ovsdbapp.exceptions.TimeoutException: Commands \[\$c\(.+\].+/\1/p"

process_log_aggr $(filter_log $LOG $module) $data_tmp $csv_path "$expr1" "$expr2"
write_meta $results_dir time $y_label
cleanup $data_tmp $csv_path
