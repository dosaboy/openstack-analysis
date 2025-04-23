# Description: capture closed connection error events - indicates missed heartbeats

LOG_MODULE="\[error\]"
Y_LABEL=missed_heartbeats
PLOT_TYPE=bar_stacked

main ()
{
    col_expr="$EXPR_LOG_DATE\+[0-9:]+ $LOG_MODULE .+ closing AMQP connection .+ \([0-9.]+:[0-9]+ -> [0-9.]+:5672 - ([a-z0-9-]+):.+\):"
    row_expr="$EXPR_LOG_DATE_GROUP_TIME\+[0-9:]+ $LOG_MODULE .+ closing AMQP connection .+ \([0-9.]+:[0-9]+ -> [0-9.]+:5672 - \${INSERT}:.+\):"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 1 true
}
