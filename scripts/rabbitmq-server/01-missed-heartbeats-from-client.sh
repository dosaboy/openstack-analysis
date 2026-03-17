# Description: capture missed heartbeats events.

LOG_NAME_FILTER=rabbit@
LOG_MODULE="\[error\]"
Y_LABEL=missed_heartbeats
PLOT_TYPE=bar_stacked
PLOT_TITLE="Missed Heartbeats from Client"
LEGEND_TITLE="AMQP Client"

main ()
{
    row_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME\+[0-9:]+ $LOG_MODULE .+ missed heartbeats from client\, timeout: .+"
    process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true $Y_LABEL
}
