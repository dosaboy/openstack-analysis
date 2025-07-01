# Description: capture resource tracking for vcpu usage.

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=nova.compute.resource_tracker
Y_LABEL=num-vcpus
PLOT_TYPE=bar_stacked

main ()
{
    row_expr="^$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT Final resource view: name=\S+ phys_ram=[0-9]+MB used_ram=[0-9]+MB phys_disk=[0-9]+GB used_disk=[0-9]+GB total_vcpus=([0-9]+) used_vcpus=([0-9]+) .+"
    keys=( total_vcpus used_vcpus )
    process_log_save_multicol $LOG $DATA_TMP $CSV_PATH "$row_expr" true ${keys[@]}
}
