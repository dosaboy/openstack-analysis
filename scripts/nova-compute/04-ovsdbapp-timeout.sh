#!/bin/bash -eu
#
# Description: capture number of ovsdbapp timeouts
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER nova.compute.manager

expr1="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT .+ ovsdbapp.exceptions.TimeoutException: Commands \[(\w+)\(.+\].+"
expr2="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT .+ ovsdbapp.exceptions.TimeoutException: Commands \[\$INSERT\(.+\].+"
process_log_aggr2 $LOG $DATA_TMP $CSV_PATH "$expr1" "$expr2" 1 true

SCRIPT_FOOTER ovsdbapp-timeouts
