# Description: capture api http return codes

skip "can take a very long time to run - enable manually if needed"

# NOTE: only run this for neutron-server logs
LOG_NAME_FILTER=neutron-server.log
LOG_MODULE=neutron.wsgi
Y_LABEL=http-return-codes
PLOT_TYPE=bar_stacked

main ()
{
    col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT [0-9.]+\,[0-9.]+ \\\"[A-Z]{3,6} /[a-z0-9.]+/[^/]+\?.*[/ ].+\" status: ([0-9]+) .+"
    row_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT [0-9.]+\,[0-9.]+ \\\"[A-Z]{3,6} /[a-z0-9.]+/[^/]+\?.*[/ ].+\\\" status: \$INSERT .+"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 0 false
}
