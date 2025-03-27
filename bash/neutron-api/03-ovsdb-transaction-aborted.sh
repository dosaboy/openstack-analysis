#!/bin/bash -eu
#
# Description: capture ovn ovsdbapp aborted transactions
#
. $SCRIPT_ROOT/lib.sh

SCRIPT_HEADER neutron.plugins.ml2.drivers.ovn.mech_driver.ovsdb.impl_idl_ovn

expr1="s/$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Transaction aborted/\1/p"
process_log_simple $(filter_log $LOG $LOG_MODULE) $DATA_TMP $CSV_PATH "$expr1" txn_aborted

SCRIPT_FOOTER txn_aborted
