#!/bin/bash -eu
#
# Description: capture api http return codes
#
. $SCRIPT_ROOT/lib/helpers.sh

skip "$(basename $0) can take a very long time to run - enable manually if needed"

SCRIPT_HEADER neutron.wsgi

expr1="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT [0-9.]+\,[0-9.]+ \\\"[A-Z]{3,6} /[a-z0-9.]+/[^/]+\?.*[/ ].+\" status: ([0-9]+) .+"
expr2="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT [0-9.]+\,[0-9.]+ \\\"[A-Z]{3,6} /[a-z0-9.]+/[^/]+\?.*[/ ].+\\\" status: \$INSERT .+"
process_log_aggr2 $LOG $DATA_TMP $CSV_PATH "$expr1" "$expr2" 1 true

SCRIPT_FOOTER http-return-codes
