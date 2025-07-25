# Description: capture number of ovsdbapp timeouts.

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=nova.compute.manager
Y_LABEL=ovsdbapp-timeouts
PLOT_TYPE=bar_stacked
PLOT_TITLE="OVSDBAPP Timeouts"

main ()
{
    col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT .+ ovsdbapp.exceptions.TimeoutException: Commands \[(\w+)\(.+\].+"
    row_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT .+ ovsdbapp.exceptions.TimeoutException: Commands \[\$INSERT\(.+\].+"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 0 true
}
