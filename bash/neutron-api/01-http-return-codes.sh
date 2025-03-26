#!/bin/bash -eu
#
# Description: capture api http return codes
#
. $SCRIPT_ROOT/lib.sh

echo "INFO: skipping $(basename $0) as it can take a very long time to run - enable manually if needed"
exit

MODULE=neutron.wsgi
. $SCRIPT_ROOT/log_expressions.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
y_label=http-return-codes
expr1="s,$EXPR_LOG_DATE $EXPR_LOG_CONTEXT [0-9.]+\,[0-9.]+ \\\"(GET|POST|HEAD|DELETE|PUT) /[a-z0-9.]+/[^/]+\?.*[/ ].+\" status: ([0-9]+) .+,\2,p"
expr2="s,$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT [0-9.]+\,[0-9.]+ \\\"(GET|POST|HEAD|DELETE|PUT) /[a-z0-9.]+/[^/]+\?.*[/ ].+\\\" status: \$INSERT .+,\1,p"

process_log_aggr $(filter_log $LOG $MODULE) $data_tmp $csv_path "$expr1" "$expr2"
write_meta $results_dir time $y_label
cleanup $data_tmp $csv_path
