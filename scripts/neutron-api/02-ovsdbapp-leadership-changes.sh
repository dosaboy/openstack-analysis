#!/bin/bash -eu
#
# Description: capture ovn leadership changes
#

# NOTE: only run this for neutron-server logs
LOG_NAME_FILTER=neutron-server.log
LOG_MODULE=ovsdbapp.backend.ovs_idl.vlog
Y_LABEL=ovn-central-db-leader-changes
PLOT_TYPE=bar_stacked

main ()
{
    col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT ssl:([0-9:.]+): clustered database server is not cluster leader; trying another server"
    row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT ssl:\$INSERT: clustered database server is not cluster leader; trying another server"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 1 true
}
