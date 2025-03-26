#!/bin/bash -eu
#
# Description: capture ovsdbapp rownotfound errors per resource type
#
. $SCRIPT_ROOT/lib.sh

MODULE=ovsdbapp.backend.ovs_idl.command
. $SCRIPT_ROOT/log_expressions.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
y_label=rownotfounds
expr1="s/$EXPR_LOG_DATE [0-9]+ \w+ $MODULE ovsdbapp.backend.ovs_idl.idlutils.RowNotFound: Cannot find (\w+) with name=.+/\1/p"
expr2="s/$EXPR_LOG_DATE_GROUP_TIME [0-9]+ \w+ $MODULE ovsdbapp.backend.ovs_idl.idlutils.RowNotFound: Cannot find \$INSERT with name=.+/\1/p"

process_log_aggr $(filter_log $LOG $MODULE) $data_tmp $csv_path "$expr1" "$expr2"
write_meta $results_dir time $y_label
cleanup $data_tmp $csv_path
