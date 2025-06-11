# Description: get time for get_pci_passthrough_devs():pci_devs_listcaps to complete

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=nova.virt.libvirt.driver
Y_LABEL=pci-devs-listcaps-delta-secs
PLOT_TYPE=bar_stacked

main ()
{
    seq_start_expr="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT_GROUP_REQ DEBUG: get_pci_passthrough_devs:pci_devs_listcaps"
    seq_end_expr="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT_GROUP_REQ DEBUG: get_pci_passthrough_devs:pci_devs_get_pcidev_info"
    process_log_deltas_no_id $LOG $DATA_TMP $CSV_PATH "$seq_start_expr" "$seq_end_expr" true
}

