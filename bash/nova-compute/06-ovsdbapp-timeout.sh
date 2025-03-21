#!/bin/bash -eu
#
# Description: capture number of ovsdbapp timeouts
#
. $SCRIPT_ROOT/lib.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
module=nova.compute.manager
e1="s/([0-9-]+) ([0-9:]+:[0-9])[0-9]:[0-9]+.[0-9]+ [0-9]+ \w+ $module .+ ovsdbapp.exceptions.TimeoutException: Commands \[(\w+)\(.+\].+/\3/p"
e2="s/([0-9-]+) ([0-9:]+:[0-9])[0-9]:[0-9]+.[0-9]+ [0-9]+ \w+ $module .+ ovsdbapp.exceptions.TimeoutException: Commands \[\$c\(.+\].+/\20/p"

process_log $(filter_log $LOG $module) $data_tmp $csv_path "$e1" "$e2"
write_meta $results_dir time ovsdbapp-timeouts
cleanup $data_tmp $csv_path
