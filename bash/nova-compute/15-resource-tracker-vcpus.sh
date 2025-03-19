#!/bin/bash -eu
#
# Description: capture resource tracking for vcpu usage
#
. $SCRIPT_ROOT/lib.sh
SCRIPT_NAME=$(basename $0| sed -r 's/[0-9]+-(.+)\.sh/\1/'| tr '-' '_')
RESULTS_DIR=results_data/$SCRIPT_NAME
mkdir -p $RESULTS_DIR

data_tmp=`mktemp -d -p $RESULTS_DIR`
csv_path=$RESULTS_DIR/${HOSTNAME}_$(basename $RESULTS_DIR).csv

module=nova.compute.resource_tracker
preamble_common="[0-9-]+ ([0-9:]+:[0-9])[0-9]:[0-9]+.[0-9]+ [0-9]+ \w+ $module \[(\S+ ?){6}\]"
expr="s/$preamble_common Final resource view: name=\S+ phys_ram=[0-9]+MB used_ram=[0-9]+MB phys_disk=[0-9]+GB used_disk=[0-9]+GB total_vcpus=([0-9]+) used_vcpus=([0-9]+) .+/\10 \3 \4/p"
keys=( total_vcpus used_vcpus )

FILTERED=$(mktemp -p $data_tmp)
grep $module $LOG > $FILTERED
process_log_simple $FILTERED $data_tmp $csv_path "$expr" ${keys[@]}

write_meta $RESULTS_DIR time num-vcpus
cleanup $data_tmp $csv_path
