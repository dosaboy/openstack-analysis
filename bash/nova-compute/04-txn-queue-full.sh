#!/bin/bash -eu
#
# Description: capture number of ovsdbapp transcation queue full errors.
#
. $SCRIPT_ROOT/lib.sh
RESULTS_DIR=results_data/$(basename $0| sed -r 's/[0-9]+-(.+)\.sh/\1/'| tr '-' '_')
mkdir -p $RESULTS_DIR

data_tmp=`mktemp -d -p $RESULTS_DIR`
csv_path=$RESULTS_DIR/${HOSTNAME}_$(basename $RESULTS_DIR).csv
module=ovsdbapp.backend.ovs_idl.command
e1="s/[0-9-]+ [0-9:.]+ [0-9]+ \w+ $module \[req-[0-9a-z-]+ ([0-9a-z-]+) ([0-9a-z-]+) .+\] .+ cause: TXN queue is full/\2/p"
e2="s/([0-9-]+) ([0-9:]+:[0-9])[0-9]:[0-9]+.[0-9]+ [0-9]+ \w+ $module \[req-[0-9a-z-]+ ([0-9a-z-]+) \$c .+\] .+ cause: TXN queue is full/\20/p"

FILTERED=$(mktemp -p $data_tmp)
grep $module $LOG > $FILTERED
process_log $FILTERED $data_tmp $csv_path "$e1" "$e2"

write_meta $RESULTS_DIR time txn-queue-full-events
cleanup $data_tmp $csv_path
