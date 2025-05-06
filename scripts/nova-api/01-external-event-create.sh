# Description: plot every time nova creates an external event

# NOTE: only run this for nova-api-wsgi logs
LOG_NAME_FILTER=nova-api-wsgi.log
LOG_MODULE=nova.api.openstack.compute.server_external_events
Y_LABEL=external_event_creates
PLOT_TYPE=bar_stacked

main ()
{
    col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT Creating event (\S+):[0-9a-z-]+ for .+"
    row_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT Creating event \$INSERT:[0-9a-z-]+ for .+"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 0 false
}
