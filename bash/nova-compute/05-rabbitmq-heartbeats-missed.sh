#!/bin/bash -eu
#
# Description: capture number rabbitmq missed heartbeats
#
. $SCRIPT_ROOT/lib.sh
RESULTS_DIR=results_data/$(basename $0| sed -r 's/[0-9]+-(.+)\.sh/\1/'| tr '-' '_')
mkdir -p $RESULTS_DIR


# override - no project ids to check
get_categories ()
{
    echo "-"
}

data_tmp=`mktemp -d -p $RESULTS_DIR`
csv_path=$RESULTS_DIR/${HOSTNAME}_$(basename $RESULTS_DIR).csv
e2='s/([0-9-]+) ([0-9:]+:[0-9])[0-9]:[0-9]+.[0-9]+ [0-9]+ \w+ oslo.messaging._drivers.impl_rabbit \[.+\] A recoverable connection\/channel error occurred, trying to reconnect: Too many heartbeats missed/\20/p'
process_log $LOG $data_tmp $csv_path "" "$e2"
write_meta $RESULTS_DIR time missed-rabbitmq-heartbeats
cleanup $data_tmp $csv_path
