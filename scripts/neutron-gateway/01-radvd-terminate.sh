# Description: 

LOG_NAME_FILTER=neutron-l3-agent.log
LOG_MODULE=neutron.agent.l3.router_info
Y_LABEL=radvd-terminate
PLOT_TYPE=bar_stacked
PLOT_TITLE="Router radvd terminations"

main ()
{
    col_expr="$EXPR_LOG_DATE $EXPR_LOG_DEFAULT Terminating radvd daemon in router device: (\S+) .+"
    row_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_DEFAULT Terminating radvd daemon in router device: \$INSERT .+"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 0 true
}
