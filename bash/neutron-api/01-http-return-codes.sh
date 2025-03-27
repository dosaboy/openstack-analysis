#!/bin/bash -eu
#
# Description: capture api http return codes
#
. $SCRIPT_ROOT/lib.sh

skip "skipping $(basename $0) as it can take a very long time to run - enable manually if needed"

SCRIPT_HEADER neutron.wsgi

expr1="s,$EXPR_LOG_DATE $EXPR_LOG_CONTEXT [0-9.]+\,[0-9.]+ \\\"(GET|POST|HEAD|DELETE|PUT) /[a-z0-9.]+/[^/]+\?.*[/ ].+\" status: ([0-9]+) .+,\2,p"
expr2="s,$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT [0-9.]+\,[0-9.]+ \\\"(GET|POST|HEAD|DELETE|PUT) /[a-z0-9.]+/[^/]+\?.*[/ ].+\\\" status: \$INSERT .+,\1,p"
process_log_aggr $(filter_log $LOG $LOG_MODULE) $DATA_TMP $CSV_PATH "$expr1" "$expr2"

SCRIPT_FOOTER http-return-codes
