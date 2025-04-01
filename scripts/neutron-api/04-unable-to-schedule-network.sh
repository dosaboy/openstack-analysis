#!/bin/bash -eu
#
# Description: plot unable to schedule network warnings
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER neutron.api.rpc.agentnotifiers.dhcp_rpc_agent_api

y_label=unable-to-schedule-network-events
expr1="s/$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Unable to schedule network ([a-z0-9-]+): no agents available.+/\1 \2/p"
process_log_tally $(filter_log $LOG $LOG_MODULE) $DATA_TMP $CSV_PATH "$expr1" $y_label

SCRIPT_FOOTER $y_label
