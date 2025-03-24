#!/bin/bash -eu
#
# Description:
#
. $SCRIPT_ROOT/lib.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
module=nova.virt.libvirt.driver
y_label=network-vif-plugged-timeouts
expr1="s/^[0-9-]+ ([0-9:]+{3})\.[0-9]+ [0-9]+ \w+ $module \[.+\] [instance: [0-9a-z-]+] Timeout waiting for \[\('network-vif-plugged', .+/\1/p"

process_log_tally $LOG $data_tmp $csv_path "$expr1" $y_label
write_meta $results_dir time $y_label
cleanup $data_tmp $csv_path
