#!/bin/bash -eu
#
# Description: capture time taken to allocate network resources for new vm.
#
. $SCRIPT_ROOT/lib.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
module=nova.network.neutron
y_label=net-info-cache-update-time
preamble_common="^([0-9-]+) ([0-9:]+{3})\.[0-9]+ [0-9]+ \w+ $module \[req-([0-9a-z-]+) [0-9a-z -]+{5}\] \[instance: [0-9a-z-]+\]"
expr1="$preamble_common allocate_for_instance\(\) allocate_for_instance .+"
expr2="$preamble_common Updating instance_info_cache with network_info:.+"
filtered=$(filter_log $LOG "$module")
# filter out updates done by the compute servive itself
filtered=$(filter_log $filtered "(\- - - - -\])|\[-\]" true)

process_log_deltas $filtered $data_tmp $csv_path "$expr1" "$expr2"
write_meta $results_dir time $y_label
cleanup $data_tmp $csv_path
