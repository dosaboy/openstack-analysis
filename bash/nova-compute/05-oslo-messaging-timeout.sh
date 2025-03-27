#!/bin/bash -eu
#
# Description: capture rpc messaging timeouts
#
. $SCRIPT_ROOT/lib.sh

SCRIPT_HEADER nova.compute.manager

expr1='s/.+/-/p'
expr2="s/$EXPR_LOG_DATE_GROUP_TIME [0-9]+ \w+ $LOG_MODULE .+ oslo_messaging.exceptions.MessagingTimeout: .+/\1/p"
process_log_aggr $(filter_log $LOG $LOG_MODULE) $DATA_TMP $CSV_PATH "$expr1" "$expr2"

SCRIPT_FOOTER rpc-timeouts
