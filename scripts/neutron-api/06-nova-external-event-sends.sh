# Description:
#    Capture every time neutron sends (responds to) an external event
#    from Nova.

# NOTE: only run this for neutron-server logs
LOG_NAME_FILTER=neutron-server.log
LOG_MODULE=neutron.notifiers.nova
Y_LABEL=nova_external_event_sends
PLOT_TYPE=bar_stacked
PLOT_TITLE="Neutron External Events"

main ()
{
    col_expr="$EXPR_LOG_DATE $EXPR_LOG_DEFAULT Sending events: .+'name': '(\S+)'.+"
    row_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_DEFAULT Sending events: .+'name': '\$INSERT'.+"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 0 false
}
