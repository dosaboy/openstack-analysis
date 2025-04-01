#!/bin/bash -eu
#
# Description: capture ovn ovsdbapp transactions and group by type
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER ovsdbapp.backend.ovs_idl.transaction

y_label=txn-command
expr1="s/$EXPR_LOG_DATE $EXPR_LOG_CONTEXT Running txn n=[0-9]+ command\(idx=[0-9]+\): (\w+)\(.+/\1/p"
expr2="s/$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Running txn n=[0-9]+ command\(idx=[0-9]+\): \$INSERT\(.+/\1/p"
process_log_aggr $(filter_log $LOG $LOG_MODULE) $DATA_TMP $CSV_PATH "$expr1" "$expr2"

SCRIPT_FOOTER $y_label
