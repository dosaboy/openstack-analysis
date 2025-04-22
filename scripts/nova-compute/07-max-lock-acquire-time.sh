#!/bin/bash -eu
#
# Description: capture amount of time nova-compute takes to acquire a lock
#

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=oslo_concurrency.lockutils
Y_LABEL=max-lock-acquire-time

main ()
{
    col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT Lock \\\"\S+\\\" acquired by \\\"(\S+)\\\" :: waited [1-9][0-9]*\.[0-9]+s .+"
    row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Lock \\\"\S+\\\" acquired by \\\"\$INSERT\\\" :: waited ([1-9][0-9]*)\.[0-9]+s .+"
    process_log_tally_multicol $(filter_log $LOG $LOG_MODULE) $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 2 true
}
