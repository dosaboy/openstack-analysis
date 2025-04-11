#!/bin/bash -eu
#
# Description: capture amount of time nova-compute takes to acquire a lock
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for nova-compute logs
[[ $LOG =~ nova-compute.log ]] || exit 0

SCRIPT_HEADER oslo_concurrency.lockutils

col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT Lock \\\"\S+\\\" acquired by \\\"(\S+)\\\" :: waited [1-9][0-9]*\.[0-9]+s .+"
row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Lock \\\"\S+\\\" acquired by \\\"\$INSERT\\\" :: waited ([1-9][0-9]*)\.[0-9]+s .+"
process_log_aggr2 $(filter_log $LOG $LOG_MODULE) $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 2 true

SCRIPT_FOOTER max-lock-acquire-time
