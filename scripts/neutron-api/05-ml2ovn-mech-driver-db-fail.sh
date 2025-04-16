#!/bin/bash -eu
#
# Description: plot OVN mechanism driver db failures
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for neutron-server logs
[[ $LOG =~ neutron-server.log ]] || exit 0

SCRIPT_HEADER neutron.plugins.ml2.managers

y_label=ovn-mech-driver-db-fail
row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Mechanism driver 'ovn' failed in (\w+): .+"
process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true $y_label

SCRIPT_FOOTER $y_label
