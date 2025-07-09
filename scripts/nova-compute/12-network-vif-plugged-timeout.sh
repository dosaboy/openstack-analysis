# Description: capture occurences of timeouts waiting for network-vif-plugged
#              events.

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=nova.compute.manager
Y_LABEL=network-vif-plugged-timeouts
PLOT_TYPE=bar_stacked

main ()
{
    col_expr="^$EXPR_LOG_DATE $EXPR_LOG_CONTEXT $EXPR_LOG_INSTANCE_UUID_GROUP_UUID Timeout waiting for \['network-vif-plugged-.+'\].+"
    row_expr="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT $EXPR_LOG_INSTANCE_UUID_INSERT_UUID Timeout waiting for \['network-vif-plugged-.+'\].+"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 0 true
}
