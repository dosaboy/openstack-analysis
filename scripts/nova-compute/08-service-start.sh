#!/bin/bash -eu
#
# Description: capture number of times nova-compute service is restarted.
#

# override - no project ids to check
get_categories ()
{
    echo "-"
}

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=nova.service
Y_LABEL=nova-compute-restarts

main ()
{
    row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_DEFAULT_INSERT_CONTEXT Starting compute node .+"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "" "$row_expr" 1 true
}
