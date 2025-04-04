#!/bin/bash -eu
#
# Description: capture ovn ovsdbapp aborted transactions
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER neutron.plugins.ml2.drivers.ovn.mech_driver.ovsdb.impl_idl_ovn

expr1="s/$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Transaction aborted/\1/p"
process_log_simple $LOG $DATA_TMP $CSV_PATH "$expr1" true txn_aborted

SCRIPT_FOOTER txn_aborted
