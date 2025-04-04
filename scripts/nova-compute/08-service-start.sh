#!/bin/bash -eu
#
# Description: capture number of times nova-compute service is restarted.
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER nova.service

expr1='s/.+/-/p'
expr2="s/$EXPR_LOG_DATE_GROUP_TIME [0-9]+ \w+ $LOG_MODULE \[-\] Starting compute node .+/\1/p"
process_log_aggr $LOG $DATA_TMP $CSV_PATH "$expr1" "$expr2" true

SCRIPT_FOOTER nova-compute-restarts
