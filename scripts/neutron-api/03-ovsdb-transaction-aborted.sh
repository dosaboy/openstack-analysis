#!/bin/bash -eu
#
# Description: capture ovn ovsdbapp aborted transactions
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for neutron-server logs
[[ $LOG =~ neutron-server.log ]] || exit 0

SCRIPT_HEADER neutron.plugins.ml2.drivers.ovn.mech_driver.ovsdb.impl_idl_ovn

row_expr="s/$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Transaction aborted. .+/\1/p"
process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true txn_aborted

SCRIPT_FOOTER txn_aborted
