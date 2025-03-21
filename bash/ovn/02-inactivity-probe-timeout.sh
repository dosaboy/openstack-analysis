#!/bin/bash -eu
#
# Description: capture api http return codes
#
. $SCRIPT_ROOT/lib.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv

module='|reconnect|'
expr1='s/[0-9-]+T([0-9:]+:[0-9])[0-9]:[0-9]+\.[0-9]+Z.+\|reconnect\|ERR\|\w+:((\S+):[0-9]+): no response to inactivity probe.+/\10 \2/p'

FILTERED=$(mktemp -p $data_tmp)
grep $module $LOG > $FILTERED
process_log_tally $FILTERED $data_tmp $csv_path "$expr1" inactivity-probe-timeouts

write_meta $results_dir time inactivity-probe-timeouts
cleanup $data_tmp $csv_path
