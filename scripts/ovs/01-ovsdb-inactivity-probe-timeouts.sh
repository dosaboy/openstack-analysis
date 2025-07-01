# Description: capture ovsdb inactivity probe timeouts.

# NOTE: only run this for ovsdb-server logs
LOG_NAME_FILTER=ovsdb-server
LOG_MODULE='\|reconnect\|'
Y_LABEL=ovsdb-inactivity-probe-timeouts
PLOT_TYPE=bar_stacked

main ()
{
    row_expr='^([0-9-]+)T([0-9:]+)\.[0-9]+Z.+\|reconnect\|ERR\|\w+:((\S+):[0-9]+): no response to inactivity probe.+'
    process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true $Y_LABEL
}
