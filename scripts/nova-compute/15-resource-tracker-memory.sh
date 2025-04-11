#!/bin/bash -eu
#
# Description: capture resource tracking for memory usage
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for nova-compute logs
[[ $LOG =~ nova-compute.log ]] || exit 0

SCRIPT_HEADER nova.compute.resource_tracker

row_expr="s/^$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Final resource view: name=\S+ phys_ram=([0-9]+)MB used_ram=([0-9]+)MB phys_disk=[0-9]+GB used_disk=[0-9]+GB total_vcpus=[0-9]+ used_vcpus=[0-9]+ .+/\1 \2 \3/p"
keys=( phys_ram used_ram )
process_log_simple $LOG $DATA_TMP $CSV_PATH "$row_expr" true ${keys[@]}

SCRIPT_FOOTER memory-mb
