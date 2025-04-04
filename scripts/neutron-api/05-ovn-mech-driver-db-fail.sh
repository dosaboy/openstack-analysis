#!/bin/bash -eu
#
# Description: plot OVN mechanism driver db failures
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER neutron.plugins.ml2.managers

y_label=ovn-mech-driver-db-fail
expr1="s/$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Mechanism driver 'ovn' failed in (\w+): .+/\1 \2/p"
process_log_tally $LOG $DATA_TMP $CSV_PATH "$expr1" true $y_label

SCRIPT_FOOTER $y_label
