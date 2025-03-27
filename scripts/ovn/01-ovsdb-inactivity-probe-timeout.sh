#!/bin/bash -eu
#
# Description: capture api http return codes
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER '|reconnect|'

expr1='s/^[0-9-]+T([0-9:]+)\.[0-9]+Z.+\|reconnect\|ERR\|\w+:((\S+):[0-9]+): no response to inactivity probe.+/\1 \2/p'
process_log_tally $(filter_log $LOG $LOG_MODULE) $DATA_TMP $CSV_PATH "$expr1" ovsdb-inactivity-probe-timeouts

SCRIPT_FOOTER ovsdb-inactivity-probe-timeouts
