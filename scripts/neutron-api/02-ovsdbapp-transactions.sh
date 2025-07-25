# Description: capture ovn ovsdbapp transactions and group by type.

# NOTE: only run this for neutron-server logs
LOG_NAME_FILTER=neutron-server.log
LOG_MODULE=ovsdbapp.backend.ovs_idl.transaction
Y_LABEL=txn-command
PLOT_TYPE=bar_stacked
PLOT_TITLE="OVS Txn Commands"

main ()
{
    col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT Running txn n=[0-9]+ command\(idx=[0-9]+\): (\w+)\(.+"
    row_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT Running txn n=[0-9]+ command\(idx=[0-9]+\): \$INSERT\(.+"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 0 false
}
