#!/bin/bash -eu
#
# Description: capture ovn leadership changes
#
. $SCRIPT_ROOT/lib.sh
SCRIPT_NAME=$(basename $0| sed -r 's/[0-9]+-(.+)\.sh/\1/'| tr '-' '_')
RESULTS_DIR=results_data/$SCRIPT_NAME
mkdir -p $RESULTS_DIR

data_tmp=`mktemp -d -p $RESULTS_DIR`
csv_path=$RESULTS_DIR/${HOSTNAME}_$(basename $RESULTS_DIR).csv

module=ovsdbapp.backend.ovs_idl.vlog
common_preamble="[0-9-]+ ([0-9:]+:[0-9])[0-9]:[0-9]+.[0-9]+ [0-9]+ \w+ $module \[(\S+ ?){6}\]"
expr1="s/$common_preamble ssl:([0-9:.]+): clustered database server is not cluster leader; trying another server/\3/p"
expr2="s/$common_preamble ssl:(\$c): clustered database server is not cluster leader; trying another server/\10/p"

FILTERED=$(mktemp -p $data_tmp)
grep $module $LOG > $FILTERED
process_log $FILTERED $data_tmp $csv_path "$expr1" "$expr2"
write_meta $RESULTS_DIR time ovn-central-db-leader-changes
cleanup $data_tmp $csv_path
