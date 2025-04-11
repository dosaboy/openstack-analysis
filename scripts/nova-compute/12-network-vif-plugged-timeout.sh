#!/bin/bash -eu
#
# Description:
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for nova-compute logs
[[ $LOG =~ nova-compute.log ]] || exit 0

SCRIPT_HEADER nova.virt.libvirt.driver

row_expr="s/^$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT $EXPR_LOG_INSTANCE_UUID Timeout waiting for \[\('network-vif-plugged', .+/\1/p"
process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true network-vif-plugged-timeouts

SCRIPT_FOOTER network-vif-plugged-timeouts
