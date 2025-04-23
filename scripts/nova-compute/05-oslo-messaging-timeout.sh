# Description: capture rpc messaging timeouts

# override - no project ids to check
get_categories ()
{
    echo "-"
}

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=nova.compute.manager
Y_LABEL=rpc-timeouts
PLOT_TYPE=bar_stacked

main ()
{
    row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_DEFAULT_INSERT_CONTEXT .+ oslo_messaging.exceptions.MessagingTimeout: .+"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "" "$row_expr" 1 true
}
