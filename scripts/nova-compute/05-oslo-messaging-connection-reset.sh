#!/bin/bash -eu
#
# Description: capture connection resets
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for nova-compute logs
[[ $LOG =~ nova-compute.log ]] || exit 0

# override - no project ids to check
get_categories ()
{
    echo "-"
}

SCRIPT_HEADER oslo.messaging._drivers.impl_rabbit

col_expr=""
row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_DEFAULT_INSERT_CONTEXT A recoverable connection\/channel error occurred\, trying to reconnect: \[Errno 104\] Connection reset by peer"
process_log_aggr2 $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 1 true

SCRIPT_FOOTER amqp-connection-resets
