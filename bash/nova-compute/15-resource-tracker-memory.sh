#!/bin/bash -eu
#
# Description: capture resource tracking for memory usage
#
. $SCRIPT_ROOT/lib.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv

module=nova.compute.resource_tracker
preamble_common="[0-9-]+ ([0-9:]+:[0-9])[0-9]:[0-9]+.[0-9]+ [0-9]+ \w+ $module \[(\S+ ?){6}\]"
expr="s/$preamble_common Final resource view: name=\S+ phys_ram=([0-9]+)MB used_ram=([0-9]+)MB phys_disk=[0-9]+GB used_disk=[0-9]+GB total_vcpus=[0-9]+ used_vcpus=[0-9]+ .+/\10 \3 \4/p"
keys=( phys_ram used_ram )

FILTERED=$(mktemp -p $data_tmp)
grep $module $LOG > $FILTERED
process_log_simple $FILTERED $data_tmp $csv_path "$expr" ${keys[@]}

write_meta $results_dir time memory-mb
cleanup $data_tmp $csv_path
