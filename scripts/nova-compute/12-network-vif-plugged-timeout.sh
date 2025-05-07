# Description: capture occurences of timeouts waiting for network-vif-plugged
#              events.

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=nova.virt.libvirt.driver
Y_LABEL=network-vif-plugged-timeouts
PLOT_TYPE=stackplot

main ()
{
    row_expr="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT $EXPR_LOG_INSTANCE_UUID Timeout waiting for \[\('network-vif-plugged'\, .+"
    process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true $Y_LABEL
}
