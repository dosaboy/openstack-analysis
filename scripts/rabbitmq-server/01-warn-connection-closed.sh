#!/bin/bash -eu
#
# Description: capture connection closed warning events - most likely indicates service restart
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER "\[warning\]"

y_label=connections_closed
col_expr="$EXPR_LOG_DATE\+[0-9:]+ $LOG_MODULE .+ closing AMQP connection .+ user: '(\w+)'.+"
row_expr="$EXPR_LOG_DATE_GROUP_TIME\+[0-9:]+ $LOG_MODULE .+ closing AMQP connection .+ user: '\$INSERT'.+"
process_log_aggr2 $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 1 true

SCRIPT_FOOTER $y_label
