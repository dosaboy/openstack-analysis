#!/bin/bash -eu
#
# Description: capture ovn ovsdbapp aborted transactions
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for neutron-server logs
[[ $LOG =~ neutron-server.log ]] || exit 0

SCRIPT_HEADER neutron.plugins.ml2.drivers.ovn.mech_driver.ovsdb.impl_idl_ovn

y_label=txn_aborted
row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Transaction aborted. .+"
process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true $y_label

SCRIPT_FOOTER $y_label
