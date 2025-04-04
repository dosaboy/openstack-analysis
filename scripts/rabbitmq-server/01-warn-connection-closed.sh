#!/bin/bash -eu
#
# Description: capture connection closed warning events - most likely indicates service restart
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER "\[warning\]"

y_label=connections_closed
expr1="s/$EXPR_LOG_DATE\+[0-9:]+ $LOG_MODULE .+ closing AMQP connection .+ user: '(\w+)'.+/\1/p"
expr2="s/$EXPR_LOG_DATE_GROUP_TIME\+[0-9:]+ $LOG_MODULE .+ closing AMQP connection .+ user: '\$INSERT'.+/\1/p"
process_log_aggr $LOG $DATA_TMP $CSV_PATH "$expr1" "$expr2" true

SCRIPT_FOOTER $y_label
