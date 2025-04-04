#!/bin/bash -eu
#
# Description: plot instances of LSP not found
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER neutron.plugins.ml2.managers

y_label=logical-switch-port-not-exists
expr1="s/$EXPR_LOG_DATE_GROUP_TIME [0-9]+ \w+ $LOG_MODULE RuntimeError: Logical Switch Port ([0-9a-z-]+) does not exist/\1 \2/p"
process_log_tally $LOG $DATA_TMP $CSV_PATH "$expr1" true $y_label

SCRIPT_FOOTER $y_label
