#!/bin/bash -eu
#
# Description: capture number of instance delete requests
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER nova.compute.manager

col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT_GROUP_USER .+ Terminating instance"
row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT_INSERT_USER .+ Terminating instance"
process_log_aggr2 $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 1 true

SCRIPT_FOOTER num-instance-deletes
