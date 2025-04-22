#!/bin/bash -eu
#
# Description: capture ovn ovsdbapp aborted transactions
#

# NOTE: only run this for neutron-server logs
LOG_NAME_FILTER=neutron-server.log
LOG_MODULE=neutron.plugins.ml2.drivers.ovn.mech_driver.ovsdb.impl_idl_ovn
Y_LABEL=txn_aborted

main ()
{
    row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Transaction aborted. .+"
    process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true $Y_LABEL
}
