#!/bin/bash -eu
#
# Description: capture number of times nova-compute service is restarted.
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for nova-compute logs
[[ $LOG =~ nova-compute.log ]] || exit 0

# override - no project ids to check
get_categories ()
{
    echo "-"
}

SCRIPT_HEADER nova.service

col_expr=""
row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_DEFAULT_INSERT_CONTEXT Starting compute node .+"
process_log_aggr2 $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 1 true

SCRIPT_FOOTER nova-compute-restarts
