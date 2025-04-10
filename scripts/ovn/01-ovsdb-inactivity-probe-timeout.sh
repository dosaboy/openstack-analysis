#!/bin/bash -eu
#
# Description: capture ovsdb inactivity probe timeouts
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for ovsdb-server logs
[[ $LOG =~ ovsdb-server ]] || exit 0

SCRIPT_HEADER '\|reconnect\|'

row_expr='s/^[0-9-]+T([0-9:]+)\.[0-9]+Z.+\|reconnect\|ERR\|\w+:((\S+):[0-9]+): no response to inactivity probe.+/\1 \2/p'
process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true ovsdb-inactivity-probe-timeouts

SCRIPT_FOOTER ovsdb-inactivity-probe-timeouts
