#!/bin/bash -eu
#
# Description: capture number of ovsdbapp timeouts
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER nova.compute.manager

expr1="s/$EXPR_LOG_DATE $EXPR_LOG_CONTEXT .+ ovsdbapp.exceptions.TimeoutException: Commands \[(\w+)\(.+\].+/\1/p"
expr2="s/$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT .+ ovsdbapp.exceptions.TimeoutException: Commands \[\$c\(.+\].+/\1/p"
process_log_aggr $(filter_log $LOG $LOG_MODULE) $DATA_TMP $CSV_PATH "$expr1" "$expr2"

SCRIPT_FOOTER ovsdbapp-timeouts
