#!/bin/bash -eu
#
# Description: capture connection closed warning events - most likely indicates service restart
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER "\[warning\]"

y_label=connections_closed
expr1="$EXPR_LOG_DATE\+[0-9:]+ $LOG_MODULE .+ closing AMQP connection .+ user: '(\w+)'.+"
expr2="$EXPR_LOG_DATE_GROUP_TIME\+[0-9:]+ $LOG_MODULE .+ closing AMQP connection .+ user: '\$INSERT'.+"
process_log_aggr2 $LOG $DATA_TMP $CSV_PATH "$expr1" "$expr2" 1 true

SCRIPT_FOOTER $y_label
