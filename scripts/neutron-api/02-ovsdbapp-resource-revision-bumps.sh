# Description: capture ovn resource revision bumps.

# NOTE: only run this for neutron-server logs
LOG_NAME_FILTER=neutron-server.log
LOG_MODULE=neutron.db.ovn_revision_numbers_db
Y_LABEL=resource-revision-bumps
PLOT_TYPE=bar_stacked
PLOT_TITLE="Resource Revision Bumps"

main ()
{
    col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT Successfully bumped revision number for resource \S+ \(type: (\S+)\) to [0-9]+"
    row_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME $EXPR_LOG_CONTEXT Successfully bumped revision number for resource \S+ \(type: \$INSERT\) to [0-9]+"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 0 true
}
