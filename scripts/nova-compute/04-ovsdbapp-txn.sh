#!/bin/bash -eu
#
# Description: capture number of ovsdbapp transactions
#
. $SCRIPT_ROOT/lib/helpers.sh

# override - no project ids to check
get_categories ()
{
    echo "-"
}

SCRIPT_HEADER ovsdbapp.backend.ovs_idl.transaction

expr1=""
expr2="s/$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Running txn .+/\1/p"
process_log_aggr $LOG $DATA_TMP $CSV_PATH "$expr1" "$expr2" true

SCRIPT_FOOTER ovsdbapp-transactions
