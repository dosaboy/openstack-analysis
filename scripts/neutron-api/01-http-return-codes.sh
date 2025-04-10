#!/bin/bash -eu
#
# Description: capture api http return codes
#
. $SCRIPT_ROOT/lib/helpers.sh

skip "$(basename $0) can take a very long time to run - enable manually if needed"

SCRIPT_HEADER neutron.wsgi

col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT [0-9.]+\,[0-9.]+ \\\"[A-Z]{3,6} /[a-z0-9.]+/[^/]+\?.*[/ ].+\" status: ([0-9]+) .+"
row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT [0-9.]+\,[0-9.]+ \\\"[A-Z]{3,6} /[a-z0-9.]+/[^/]+\?.*[/ ].+\\\" status: \$INSERT .+"
process_log_aggr2 $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 1 false

SCRIPT_FOOTER http-return-codes
