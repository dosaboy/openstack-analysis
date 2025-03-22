#!/bin/bash -eu
#
# Description: capture ovn leadership changes
#
. $SCRIPT_ROOT/lib.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv

module=ovsdbapp.backend.ovs_idl.vlog
common_preamble="[0-9-]+ ([0-9:]+:[0-9])[0-9]:[0-9]+.[0-9]+ [0-9]+ \w+ $module \[(\S+ ?){6}\]"
expr1="s/$common_preamble ssl:([0-9:.]+): clustered database server is not cluster leader; trying another server/\3/p"
expr2="s/$common_preamble ssl:(\$c): clustered database server is not cluster leader; trying another server/\10/p"

process_log_aggr $(filter_log $LOG $module) $data_tmp $csv_path "$expr1" "$expr2"
write_meta $results_dir time ovn-central-db-leader-changes
cleanup $data_tmp $csv_path
