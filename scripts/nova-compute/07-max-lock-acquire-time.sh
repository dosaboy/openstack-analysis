#!/bin/bash -eu
#
# Description: capture amount of time nova-compute takes to acquire a lock
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER oslo_concurrency.lockutils

expr1="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT Lock \\\"\S+\\\" acquired by \\\"(\S+)\\\" :: waited [1-9][0-9]*\.[0-9]+s .+"
expr2="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Lock \\\"\S+\\\" acquired by \\\"\$INSERT\\\" :: waited ([1-9][0-9]*)\.[0-9]+s .+"
process_log_aggr2 $(filter_log $LOG $LOG_MODULE) $DATA_TMP $CSV_PATH "$expr1" "$expr2" 2 true

SCRIPT_FOOTER max-lock-acquire-time
