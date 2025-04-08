#!/bin/bash -eu
#
# Description: capture ovsdb router bind to host counts
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER neutron.plugins.ml2.drivers.ovn.mech_driver.ovsdb.ovsdb_monitor

expr1="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT Router (\S+) is bound to host \S+"
expr2="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Router \$INSERT is bound to host \S+"
process_log_aggr2 $LOG $DATA_TMP $CSV_PATH "$expr1" "$expr2" 1 true

SCRIPT_FOOTER router-bound-to-host
