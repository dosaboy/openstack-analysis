# Description: capture connection closed warning events - most likely indicates
#              service restart.

LOG_MODULE="\[warning\]"
Y_LABEL=connections_closed
PLOT_TYPE=bar_stacked

main ()
{
    col_expr="$EXPR_LOG_DATE\+[0-9:]+ $LOG_MODULE .+ closing AMQP connection .+ user: '(\w+)'.+"
    row_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME\+[0-9:]+ $LOG_MODULE .+ closing AMQP connection .+ user: '\$INSERT'.+"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 0 true
}
