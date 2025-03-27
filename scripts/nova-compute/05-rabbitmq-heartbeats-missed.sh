#!/bin/bash -eu
#
# Description: capture number rabbitmq missed heartbeats
#
. $SCRIPT_ROOT/lib/helpers.sh

# override - no project ids to check
get_categories ()
{
    echo "-"
}

SCRIPT_HEADER oslo.messaging._drivers.impl_rabbit

expr1=""
expr2="s/$EXPR_LOG_DATE_GROUP_TIME [0-9]+ \w+ $LOG_MODULE \[.+\] A recoverable connection\/channel error occurred, trying to reconnect: Too many heartbeats missed/\1/p"
process_log_aggr $(filter_log $LOG $LOG_MODULE) $DATA_TMP $CSV_PATH "$expr1" "$expr2"

SCRIPT_FOOTER missed-rabbitmq-heartbeats
