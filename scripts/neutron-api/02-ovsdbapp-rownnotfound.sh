# Description: capture ovsdbapp rownotfound errors per resource type.

# NOTE: only run this for neutron-server logs
LOG_NAME_FILTER=neutron-server.log
LOG_MODULE=ovsdbapp.backend.ovs_idl.command
Y_LABEL=rownotfounds
PLOT_TYPE=bar_stacked

main ()
{
    col_expr="$EXPR_LOG_DATE [0-9]+ \w+ $LOG_MODULE ovsdbapp.backend.ovs_idl.idlutils.RowNotFound: Cannot find (\w+) with name=.+"
    row_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME [0-9]+ \w+ $LOG_MODULE ovsdbapp.backend.ovs_idl.idlutils.RowNotFound: Cannot find \$INSERT with name=.+"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 0 true
}
