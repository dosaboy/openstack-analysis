#!/bin/bash -eu
#
# Description:
#
. $SCRIPT_ROOT/lib.sh

SCRIPT_HEADER nova.virt.libvirt.driver

expr1="s/^$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT $EXPR_LOG_INSTANCE_UUID Timeout waiting for \[\('network-vif-plugged', .+/\1/p"
process_log_tally $LOG $DATA_TMP $CSV_PATH "$expr1" network-vif-plugged-timeouts

SCRIPT_FOOTER network-vif-plugged-timeouts
