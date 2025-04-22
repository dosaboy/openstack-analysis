#!/bin/bash -eu
#
# Description: capture number of ovsdbapp transactions
#

# override - no project ids to check
get_categories ()
{
    echo "-"
}

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=ovsdbapp.backend.ovs_idl.transaction
Y_LABEL=ovsdbapp-transactions
PLOT_TYPE=bar_stacked

main ()
{
    row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_DEFAULT_INSERT_CONTEXT Running txn .+"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "" "$row_expr" 1 true
}
