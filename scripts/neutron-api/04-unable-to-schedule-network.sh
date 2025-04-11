#!/bin/bash -eu
#
# Description: plot unable to schedule network warnings
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for neutron-server logs
[[ $LOG =~ neutron-server.log ]] || exit 0

SCRIPT_HEADER neutron.api.rpc.agentnotifiers.dhcp_rpc_agent_api

y_label=unable-to-schedule-network-events
row_expr="s/$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Unable to schedule network ([a-z0-9-]+): no agents available.+/\1 \2/p"
process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true $y_label

SCRIPT_FOOTER $y_label
