#!/bin/bash -eu
#
# Description: capture number of aborted instance create requests
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER nova.compute.manager

expr1="s/$EXPR_LOG_DATE $EXPR_LOG_CONTEXT_GROUP_USER .+ Build of instance [a-z0-9-]+ aborted: .+/\1/p"
expr2="s/$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT_INSERT_USER .+ Build of instance [a-z0-9-]+ aborted: .+/\1/p"
process_log_aggr $(filter_log $LOG $LOG_MODULE) $DATA_TMP $CSV_PATH "$expr1" "$expr2"

SCRIPT_FOOTER aborted-instance-creates
