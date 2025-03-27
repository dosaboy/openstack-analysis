#!/bin/bash -eu
#
# Description: capture time taken to allocate network resources for new vm.
#
. $SCRIPT_ROOT/lib.sh

SCRIPT_HEADER os_vif

expr1="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT_GROUP_REQ Plugging vif .+"
expr2="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT_GROUP_REQ Successfully plugged vif .+"
process_log_deltas $(filter_log $LOG $LOG_MODULE) $DATA_TMP $CSV_PATH "$expr1" "$expr2"

SCRIPT_FOOTER os-vif-plug-time
