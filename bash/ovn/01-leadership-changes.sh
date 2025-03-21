#!/bin/bash -eu
#
# Description: capture api http return codes
#
. $SCRIPT_ROOT/lib.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv

module=neutron.wsgi
preamble_common="[0-9-]+ ([0-9:]+:[0-9])[0-9]:[0-9]+.[0-9]+ [0-9]+ \w+ $module \[(\S+ ?){6}\] [0-9.]+\,[0-9.]+"
expr1="s,$preamble_common \"(GET|POST|HEAD|DELETE|PUT) /[a-z0-9.]+/[^/]+\?.*[/ ].+\" status: ([0-9]+) .+,\4,p"
expr2="s,$preamble_common \\\"(GET|POST|HEAD|DELETE|PUT) /[a-z0-9.]+/[^/]+\?.*[/ ].+\\\" status: \$c .+,\10,p"

FILTERED=$(mktemp -p $data_tmp)
grep $module $LOG > $FILTERED
process_log $FILTERED $data_tmp $csv_path "$expr1" "$expr2"

write_meta $results_dir time http-return-codes
cleanup $data_tmp $csv_path
