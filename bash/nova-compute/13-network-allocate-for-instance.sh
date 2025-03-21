#!/bin/bash -eu
#
# Description: capture time taken to allocate network resources for new vm.
#
. $SCRIPT_ROOT/lib.sh

process_log ()
{
    local LOG=$1
    local DATA_TMP=$2
    local csv_path=$3
    local CATCMD
    local MAX_JOBS=10
    local NUM_JOBS=0
    local key=
    local current=
    local path=

    ensure_csv_path $csv_path
    file --mime-type $LOG| grep -q application/gzip && CATCMD=zcat || CATCMD=cat

    preamble_common='[0-9-]+ ([0-9:]+:[0-9])[0-9]:[0-9]+.[0-9]+ [0-9]+ \w+ nova.network.neutron \[req-[0-9a-z-]+ ([0-9a-z-]+) ([0-9a-z-]+) .+\] \[instance: ([0-9a-z-]+)\]'

    e1="s/$preamble_common allocate_for_instance\(\) allocate_for_instance .+/\0/p"
    # NOTE: exclude service thread
    readarray -t starts<<<$(get_categories $CATCMD $LOG "$e1"| grep -v "\- - - - -]")
    (( ${#starts[@]} )) && [[ -n ${starts[0]} ]] || return

    e2="s/$preamble_common Updating instance_info_cache with network_info:.+/\0/p"
    # NOTE: exclude service thread
    readarray -t ends<<<$(get_categories $CATCMD $LOG "$e2"| grep -v "\- - - - -]")
    (( ${#ends[@]} )) && [[ -n ${ends[0]} ]] || return

    declare -A UPDATE_STARTS=()
    declare -A UPDATE_ENDS=()

    for line in "${starts[@]}"; do
        info=( $(echo "$line"| sed -rn 's/^[0-9-]+ ([0-9:]+:[0-9:]+[0-9:]+).[0-9]+ [0-9]+ .+ \[req-([0-9a-z-]+) .+/\1 \2/p') )
        start=${info[0]}
        req=${info[1]}
        [[ ${UPDATE_STARTS[$req]:-null} = null ]] || echo "WARNING: req-$req found more than once"
        UPDATE_STARTS[$req]=$start
    done

    for line in "${ends[@]}"; do
        info=( $(echo "$line"| sed -rn 's/^[0-9-]+ ([0-9:]+:[0-9:]+[0-9:]+).[0-9]+ [0-9]+ .+ \[req-([0-9a-z-]+) .+/\1 \2/p') )
        ends=${info[0]}
        req=${info[1]}
        UPDATE_ENDS[$req]=$ends
    done

    key=$(get_script_name)
    init_dataset $DATA_TMP "" ${key}_max
    for req in ${!UPDATE_STARTS[@]}; do
        [[ -n ${UPDATE_ENDS[$req]:-""} ]] || continue
        info=( $(python3 $SCRIPT_ROOT/../python/datecheck.py ${UPDATE_STARTS[$req]} ${UPDATE_ENDS[$req]}) )
        ((${#info[@]})) || continue
        t=${info[0]}
        path=${DATA_TMP}/${t//:/_}
        current=$(cat $path/${key}_max)
        ((current<${info[1]})) || continue
        echo ${info[1]} > $path/${key}_max
    done
    create_csv $csv_path $DATA_TMP
}

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
module=nova.network.neutron

process_log $(filter_log $LOG $module) $data_tmp $csv_path
write_meta $results_dir time net-allocate-time
cleanup $data_tmp $csv_path
