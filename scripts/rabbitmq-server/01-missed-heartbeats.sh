#!/bin/bash -eu
#
# Description: capture closed connection error events - indicates missed heartbeats
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER "\[error\]"

y_label=missed_heartbeats
expr1="s/$EXPR_LOG_DATE\+[0-9:]+ $LOG_MODULE .+ closing AMQP connection .+ \([0-9.]+:[0-9]+ -> [0-9.]+:5672 - ([a-z0-9-]+):.+\):/\1/p"
expr2="s/$EXPR_LOG_DATE_GROUP_TIME\+[0-9:]+ $LOG_MODULE .+ closing AMQP connection .+ \([0-9.]+:[0-9]+ -> [0-9.]+:5672 - \${INSERT}:.+\):/\1/p"
process_log_aggr $LOG $DATA_TMP $CSV_PATH "$expr1" "$expr2" true

SCRIPT_FOOTER $y_label
