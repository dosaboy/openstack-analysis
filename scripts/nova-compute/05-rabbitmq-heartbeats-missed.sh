#!/bin/bash -eu
#
# Description: capture number rabbitmq missed heartbeats
#

# override - no project ids to check
get_categories ()
{
    echo "-"
}

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=oslo.messaging._drivers.impl_rabbit
Y_LABEL=missed-rabbitmq-heartbeats
PLOT_TYPE=bar_stacked

main ()
{
    row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_DEFAULT_INSERT_CONTEXT A recoverable connection\/channel error occurred\, trying to reconnect: Too many heartbeats missed"
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "" "$row_expr" 1 true
}
