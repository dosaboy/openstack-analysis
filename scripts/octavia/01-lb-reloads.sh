# Description: get number of loadbalancer reload requests.

# NOTE: only run this for octavia-worker logs
LOG_NAME_FILTER=octavia-worker.log
LOG_MODULE=octavia.amphorae.drivers.haproxy.rest_api_driver
Y_LABEL=lb-reloads
PLOT_TYPE=bar_stacked
PLOT_TITLE="LB Reloads"
LEGEND_TITLE="LB ID"

main ()
{
    col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT request url loadbalancer/([a-z0-9-]+)/reload .+"
    row_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT request url loadbalancer/\$INSERT+/reload .+"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 0 true
}
