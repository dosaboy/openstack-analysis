#!/bin/bash -eu
#
# Description: capture resource tracking for vcpu usage
#
. $SCRIPT_ROOT/lib.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv

module=nova.compute.resource_tracker
preamble_common="[0-9-]+ ([0-9:]+{3}).[0-9]+ [0-9]+ \w+ $module \[(\S+ ?){6}\]"
expr="s/$preamble_common Final resource view: name=\S+ phys_ram=[0-9]+MB used_ram=[0-9]+MB phys_disk=[0-9]+GB used_disk=[0-9]+GB total_vcpus=([0-9]+) used_vcpus=([0-9]+) .+/\1 \3 \4/p"
keys=( total_vcpus used_vcpus )

process_log_simple $(filter_log $LOG $module) $data_tmp $csv_path "$expr" ${keys[@]}
write_meta $results_dir time num-vcpus
cleanup $data_tmp $csv_path
