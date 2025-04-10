#!/bin/bash -eu
#
# Description: capture rpc messaging timeouts
#
. $SCRIPT_ROOT/lib/helpers.sh

# override - no project ids to check
get_categories ()
{
    echo "-"
}

SCRIPT_HEADER nova.compute.manager

col_expr=""
row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_DEFAULT_INSERT_CONTEXT .+ oslo_messaging.exceptions.MessagingTimeout: .+"
process_log_aggr2 $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 1 true

SCRIPT_FOOTER rpc-timeouts
