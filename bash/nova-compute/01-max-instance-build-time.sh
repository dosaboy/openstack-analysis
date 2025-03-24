#!/bin/bash -eu
#
# Description: capture max amount of time taken to build instances.
#
. $SCRIPT_ROOT/lib.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
module=nova.compute.manager
y_label=max-instance-build-time
expr1="s/[0-9-]+ [0-9:.]+ [0-9]+ \w+ $module \[req-[0-9a-z-]+ [0-9a-z-]+ ([0-9a-z-]+) .+\] .+ Took [0-9.]+ seconds to build instance./\1/p"
expr2="s/[0-9-]+ ([0-9:]+{3}).[0-9]+ [0-9]+ \w+ $module \[req-[0-9a-z-]+ [0-9a-z-]+ \$c .+\] Took ([0-9]+).[0-9]+ seconds to build instance./\1 \2/p"

process_log_max $(filter_log $LOG $module) $data_tmp $csv_path "$expr1" "$expr2"
write_meta $results_dir time $y_label
cleanup $data_tmp $csv_path
