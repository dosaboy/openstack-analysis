# Description: capture ovn northd high CPU usage.

# NOTE: only run this for ovn-northd logs
LOG_NAME_FILTER=ovn-northd.log
LOG_MODULE='\|poll_loop\|'
Y_LABEL=ovn-northd-cpu-usage-max
PLOT_TYPE=bar_stacked

main ()
{
    col_expr='^[0-9-]+T[0-9:]+\.[0-9]+Z.+\|poll_loop\|INFO\|.+ \([0-9.]+:[0-9]+<->[0-9.]+:([0-9]+)\) .+ \([0-9]+% CPU usage\)'
    # NOTE: we use a third group as the value to override the default tally
    row_expr='^([0-9-]+)T([0-9:]+)\.[0-9]+Z.+\|poll_loop\|INFO\|.+ \([0-9.]+:[0-9]+<->[0-9.]+:$INSERT\) .+ \(([0-9]+)% CPU usage\)'
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 1 true
}
