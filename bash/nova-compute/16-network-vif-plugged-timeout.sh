#!/bin/bash -eu
#
# Description:
#
. $SCRIPT_ROOT/lib.sh

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv

module=nova.virt.libvirt.driver


#2025-02-20 04:28:22.820 5151 WARNING nova.virt.libvirt.driver [req-21591c5e-6884-45cf-bd9a-967c6d8b5fd0 607ef15c4b0a4589b2511917afd0d513 4337fd8116b84c1398d98bfe268b6aef - ca701209ba92430f9c4cbb37d096f84f #ca701209ba92430f9c4cbb37d096f84f] [instance: 614387fc-6a29-4504-a4c4-f91269fe0dba] Timeout waiting for [('network-vif-plugged', '992ae730-2d58-476f-83bf-07b00db56186')] for instance with vm_state building and task_state #spawning.: eventlet.timeout.Timeout: 1000 seconds

y_label=network-vif-plugged-timeouts
e1="s/^[0-9-]+ ([0-9:]+{3})\.[0-9]+ [0-9]+ \w+ $module \[.+\] [instance: [0-9a-z-]+] Timeout waiting for \[\('network-vif-plugged', .+/\1/p"
process_log_tally $LOG $data_tmp $csv_path "$e1" $y_label

write_meta $results_dir time $y_label
cleanup $data_tmp $csv_path
