#!/bin/bash -eu
#
# Description: capture connection resets
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER oslo.messaging._drivers.impl_rabbit

expr1='s/.+/-/p'
expr2="s/$EXPR_LOG_DATE_GROUP_TIME [0-9]+ \w+ $LOG_MODULE .+ A recoverable connection\/channel error occurred, trying to reconnect: \[Errno 104\] Connection reset by peer/\1/p"
process_log_aggr $LOG $DATA_TMP $CSV_PATH "$expr1" "$expr2" true

SCRIPT_FOOTER amqp-connection-resets
