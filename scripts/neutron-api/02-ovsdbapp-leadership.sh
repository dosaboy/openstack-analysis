#!/bin/bash -eu
#
# Description: capture ovn leadership changes
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER ovsdbapp.backend.ovs_idl.vlog

expr1="s/$EXPR_LOG_DATE $EXPR_LOG_CONTEXT ssl:([0-9:.]+): clustered database server is not cluster leader; trying another server/\1/p"
expr2="s/$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT ssl:(\$c): clustered database server is not cluster leader; trying another server/\1/p"
process_log_aggr $LOG $DATA_TMP $CSV_PATH "$expr1" "$expr2" true

SCRIPT_FOOTER ovn-central-db-leader-changes
