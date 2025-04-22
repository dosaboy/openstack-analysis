#!/bin/bash -eu
#
# Description: plot unable to schedule network warnings
#

# NOTE: only run this for neutron-server logs
LOG_NAME_FILTER=neutron-server.log
LOG_MODULE=neutron.api.rpc.agentnotifiers.dhcp_rpc_agent_api
Y_LABEL=unable-to-schedule-network-events

main ()
{
    row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Unable to schedule network [a-z0-9-]+: no agents available.+"
    process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true $Y_LABEL
}
