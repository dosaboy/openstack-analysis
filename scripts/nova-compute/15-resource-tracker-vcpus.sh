#!/bin/bash -eu
#
# Description: capture resource tracking for vcpu usage
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER nova.compute.resource_tracker

expr="s/^$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Final resource view: name=\S+ phys_ram=[0-9]+MB used_ram=[0-9]+MB phys_disk=[0-9]+GB used_disk=[0-9]+GB total_vcpus=([0-9]+) used_vcpus=([0-9]+) .+/\1 \2 \3/p"
keys=( total_vcpus used_vcpus )
process_log_simple $LOG $DATA_TMP $CSV_PATH "$expr" true ${keys[@]}

SCRIPT_FOOTER num-vcpus
