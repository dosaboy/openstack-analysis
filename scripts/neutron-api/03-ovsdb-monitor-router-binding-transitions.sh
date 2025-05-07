# Description: capture ovsdb router bind to host counts.

# NOTE: only run this for neutron-server logs
LOG_NAME_FILTER=neutron-server.log
LOG_MODULE=neutron.plugins.ml2.drivers.ovn.mech_driver.ovsdb.ovsdb_monitor
Y_LABEL=router-bound-to-host
PLOT_TYPE=bar_stacked

main ()
{
    col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT Router (\S+) is bound to host \S+"
    row_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT Router \$INSERT is bound to host \S+"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 0 true
}
