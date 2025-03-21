#!/bin/bash -eu
#
# Description: capture number of ovsdbapp transactions
#
. $SCRIPT_ROOT/lib.sh

# override - no project ids to check
get_categories ()
{
    echo "-"
}

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
module=ovsdbapp.backend.ovs_idl.transaction
e1=""
e2="s/[0-9-]+ ([0-9:]+:[0-9])[0-9]:[0-9]+.[0-9]+ [0-9]+ \w+ $module \[.+\] Running txn .+/\10/p"

process_log $(filter_log $LOG $module) $data_tmp $csv_path "$e1" "$e2"
write_meta $results_dir time ovsdbapp-transactions
cleanup $data_tmp $csv_path
