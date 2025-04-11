#!/bin/bash -eu
#
# Description: capture ovn ovsdbapp transactions and group by type
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for neutron-server logs
[[ $LOG =~ neutron-server.log ]] || exit 0

SCRIPT_HEADER ovsdbapp.backend.ovs_idl.transaction

y_label=txn-command
col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT Running txn n=[0-9]+ command\(idx=[0-9]+\): (\w+)\(.+"
row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Running txn n=[0-9]+ command\(idx=[0-9]+\): \$INSERT\(.+"
process_log_aggr2 $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 1 false

SCRIPT_FOOTER $y_label
