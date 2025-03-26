#!/bin/bash -eu
#
# Description: capture ovn resource revision bumps
#
. $SCRIPT_ROOT/lib.sh

MODULE=neutron.db.ovn_revision_numbers_db
. $SCRIPT_ROOT/log_expressions.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
y_label=resource-revision-bumps
expr1="s/$EXPR_LOG_DATE $EXPR_LOG_CONTEXT Successfully bumped revision number for resource (\S+) \(type: \S+\) to \d+/\1/p"
expr2="s/$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Successfully bumped revision number for resource \$INSERT \(type: \S+\) to \d+/\1/p"

process_log_aggr $(filter_log $LOG $MODULE) $data_tmp $csv_path "$expr1" "$expr2"
write_meta $results_dir time $y_label
cleanup $data_tmp $csv_path
