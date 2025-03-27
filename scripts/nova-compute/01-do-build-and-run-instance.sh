#!/bin/bash -eu
#
# Description: capture number of instance create requests
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER nova.compute.manager

expr1="s/$EXPR_LOG_DATE $EXPR_LOG_CONTEXT_GROUP_USER .+ _do_build_and_run_instance .+/\1/p"
expr2="s/$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT_INSERT_USER .+ _do_build_and_run_instance .+/\1/p"
process_log_aggr $(filter_log $LOG $LOG_MODULE) $DATA_TMP $CSV_PATH "$expr1" "$expr2"

SCRIPT_FOOTER num-instance-creates
