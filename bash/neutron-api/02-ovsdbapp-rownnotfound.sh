#!/bin/bash -eu
#
# Description: capture ovsdbapp rownotfound errors per resource type
#
. $SCRIPT_ROOT/lib.sh

SCRIPT_HEADER ovsdbapp.backend.ovs_idl.command

expr1="s/$EXPR_LOG_DATE [0-9]+ \w+ $LOG_MODULE ovsdbapp.backend.ovs_idl.idlutils.RowNotFound: Cannot find (\w+) with name=.+/\1/p"
expr2="s/$EXPR_LOG_DATE_GROUP_TIME [0-9]+ \w+ $LOG_MODULE ovsdbapp.backend.ovs_idl.idlutils.RowNotFound: Cannot find \$INSERT with name=.+/\1/p"
process_log_aggr $(filter_log $LOG $LOG_MODULE) $DATA_TMP $CSV_PATH "$expr1" "$expr2"

SCRIPT_FOOTER rownotfounds
