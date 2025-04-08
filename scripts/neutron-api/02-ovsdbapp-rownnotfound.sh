#!/bin/bash -eu
#
# Description: capture ovsdbapp rownotfound errors per resource type
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER ovsdbapp.backend.ovs_idl.command

expr1="$EXPR_LOG_DATE [0-9]+ \w+ $LOG_MODULE ovsdbapp.backend.ovs_idl.idlutils.RowNotFound: Cannot find (\w+) with name=.+"
expr2="$EXPR_LOG_DATE_GROUP_TIME [0-9]+ \w+ $LOG_MODULE ovsdbapp.backend.ovs_idl.idlutils.RowNotFound: Cannot find \$INSERT with name=.+"
process_log_aggr2 $LOG $DATA_TMP $CSV_PATH "$expr1" "$expr2" 1 true

SCRIPT_FOOTER rownotfounds
