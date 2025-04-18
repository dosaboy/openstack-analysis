#!/bin/bash -eu
#
# Description: capture closed connection error events - indicates missed heartbeats
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER "\[error\]"

y_label=missed_heartbeats
col_expr="$EXPR_LOG_DATE\+[0-9:]+ $LOG_MODULE .+ closing AMQP connection .+ \([0-9.]+:[0-9]+ -> [0-9.]+:5672 - ([a-z0-9-]+):.+\):"
row_expr="$EXPR_LOG_DATE_GROUP_TIME\+[0-9:]+ $LOG_MODULE .+ closing AMQP connection .+ \([0-9.]+:[0-9]+ -> [0-9.]+:5672 - \${INSERT}:.+\):"
process_log_aggr2 $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 1 true

SCRIPT_FOOTER $y_label
