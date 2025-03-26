#!/bin/bash -eu
#
# Description: capture ovn ovsdbapp aborted transactions
#
. $SCRIPT_ROOT/lib.sh

MODULE=neutron.plugins.ml2.drivers.ovn.mech_driver.ovsdb.impl_idl_ovn
. $SCRIPT_ROOT/log_expressions.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
y_label=txn_aborted
expr1="s/$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Transaction aborted/\1/p"

process_log_simple $(filter_log $LOG $MODULE) $data_tmp $csv_path "$expr1" txn_aborted
write_meta $results_dir time $y_label
cleanup $data_tmp $csv_path
