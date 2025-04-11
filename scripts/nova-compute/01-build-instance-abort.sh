#!/bin/bash -eu
#
# Description: capture number of aborted instance create requests
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for nova-compute logs
[[ $LOG =~ nova-compute.log ]] || exit 0

SCRIPT_HEADER nova.compute.manager

col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT_GROUP_USER .+ Build of instance [a-z0-9-]+ aborted: .+"
row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT_INSERT_USER .+ Build of instance [a-z0-9-]+ aborted: .+"
process_log_aggr2 $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 1 true

SCRIPT_FOOTER aborted-instance-creates
