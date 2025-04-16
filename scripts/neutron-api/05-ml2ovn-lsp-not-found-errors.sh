#!/bin/bash -eu
#
# Description: plot instances of LSP not found
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for neutron-server logs
[[ $LOG =~ neutron-server.log ]] || exit 0

SCRIPT_HEADER neutron.plugins.ml2.managers

y_label=logical-switch-port-not-exists
row_expr="$EXPR_LOG_DATE_GROUP_TIME [0-9]+ \w+ $LOG_MODULE RuntimeError: Logical Switch Port ([0-9a-z-]+) does not exist"
process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true $y_label

SCRIPT_FOOTER $y_label
