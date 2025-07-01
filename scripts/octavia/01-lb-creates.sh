# Description: get number of loadbalancer create requests.

# NOTE: only run this for octavia-worker logs
LOG_NAME_FILTER=octavia-worker.log
LOG_MODULE=octavia.controller.queue.v1.endpoints
Y_LABEL=lb-creates
PLOT_TYPE=bar_stacked

main ()
{
    row_expr="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME [0-9]+ \w+ $LOG_MODULE \[-\] Creating load balancer '\S+'..."
    process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true $Y_LABEL
}
