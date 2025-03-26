#!/bin/bash -eu
#
# Description: capture ovsdb router bind to host counts
#
. $SCRIPT_ROOT/lib.sh

MODULE=neutron.plugins.ml2.drivers.ovn.mech_driver.ovsdb.ovsdb_monitor
. $SCRIPT_ROOT/log_expressions.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
y_label=router-bound-to-host

expr1="s/$EXPR_LOG_DATE $EXPR_LOG_CONTEXT Router (\S+) is bound to host \S+/\1/p"
expr2="s/$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Router \$INSERT is bound to host (\S+)/\1/p"

process_log_aggr $(filter_log $LOG $MODULE) $data_tmp $csv_path "$expr1" "$expr2"
write_meta $results_dir time $y_label
cleanup $data_tmp $csv_path
