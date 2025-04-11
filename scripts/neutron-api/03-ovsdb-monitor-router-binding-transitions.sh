#!/bin/bash -eu
#
# Description: capture ovsdb router bind to host counts
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for neutron-server logs
[[ $LOG =~ neutron-server.log ]] || exit 0

SCRIPT_HEADER neutron.plugins.ml2.drivers.ovn.mech_driver.ovsdb.ovsdb_monitor

col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT Router (\S+) is bound to host \S+"
row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Router \$INSERT is bound to host \S+"
process_log_aggr2 $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 1 true

SCRIPT_FOOTER router-bound-to-host
