#!/bin/bash -eu
#
# Description: capture number of times nova-compute service is restarted.
#
. $SCRIPT_ROOT/lib.sh
RESULTS_DIR=results_data/$(basename $0| sed -r 's/[0-9]+-(.+)\.sh/\1/'| tr '-' '_')
mkdir -p $RESULTS_DIR

data_tmp=`mktemp -d -p $RESULTS_DIR`
csv_path=$RESULTS_DIR/${HOSTNAME}_$(basename $RESULTS_DIR).csv
e1='s/.+/-/p'
e2='s/([0-9-]+) ([0-9:]+:[0-9])[0-9]:[0-9]+.[0-9]+ [0-9]+ \w+ nova.service \[-\] Starting compute node .+/\20/p'
process_log $LOG $data_tmp $csv_path "$e1" "$e2"
write_meta $RESULTS_DIR time nova-compute-restart
cleanup $data_tmp $csv_path
