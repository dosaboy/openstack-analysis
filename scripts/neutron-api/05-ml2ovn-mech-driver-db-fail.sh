# Description: plot OVN mechanism driver db failures

# NOTE: only run this for neutron-server logs
LOG_NAME_FILTER=neutron-server.log
LOG_MODULE=neutron.plugins.ml2.managers
Y_LABEL=ovn-mech-driver-db-fail
PLOT_TYPE=stackplot

main ()
{
    row_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT Mechanism driver 'ovn' failed in \w+: .+"
    process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true $Y_LABEL
}
