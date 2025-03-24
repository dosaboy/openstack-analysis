#!/bin/bash -eu
#
# Description: capture time taken to allocate network resources for new vm.
#
. $SCRIPT_ROOT/lib.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
module=os_vif
y_label=os-vif-plug-time
preamble_common="^([0-9-]+) ([0-9:]+{3})\.[0-9]+ [0-9]+ \w+ $module \[(req-[0-9a-z -]+) [0-9a-z -]+{5}\]"
expr1="$preamble_common Plugging vif .+"
expr2="$preamble_common Successfully plugged vif .+"

process_log_deltas $(filter_log $LOG $module) $data_tmp $csv_path "$expr1" "$expr2"
write_meta $results_dir time $y_label
cleanup $data_tmp $csv_path
