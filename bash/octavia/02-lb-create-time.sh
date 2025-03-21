#!/bin/bash -eu
#
# Description:
#
. $SCRIPT_ROOT/lib.sh

process_log ()
{
    local LOG=$1
    local DATA_TMP=$2
    local CSV_PATH=$3
    local EXPR1="$4"
    local EXPR2="$5"
    local CATCMD=cat
    local MAX_JOBS=10
    local NUM_JOBS=0
    local key=
    local current=
    local path=

    ensure_csv_path
    file --mime-type $LOG| grep -q application/gzip && CATCMD=zcat

    # NOTE: exclude service thread
    readarray -t starts<<<$(get_categories $CATCMD $LOG "s/$EXPR1/\0/p")
    (( ${#starts[@]} )) && [[ -n ${starts[0]} ]] || return

    echo "${#starts[@]}"

    # NOTE: exclude service thread
    readarray -t ends<<<$(get_categories $CATCMD $LOG "s/$EXPR2/\0/p")
    (( ${#ends[@]} )) && [[ -n ${ends[0]} ]] || return

    declare -A UPDATE_STARTS=()
    declare -A UPDATE_ENDS=()

    for line in "${starts[@]}"; do
        info=( $(echo "$line"| sed -rn "s/$EXPR1/\1 \2/p") )
        start=${info[0]}
        resource=${info[1]}
        [[ ${UPDATE_STARTS[$resource]:-null} = null ]] || echo "WARNING: resource $resource found more than once"
        UPDATE_STARTS[$resource]=$start
    done

    for line in "${ends[@]}"; do
        info=( $(echo "$line"| sed -rn "s/$EXPR2/\1 \3/p") )
        ends=${info[0]}
        resource=${info[1]}
        UPDATE_ENDS[$resource]=$ends
    done

    key=$(get_script_name)
    init_dataset $DATA_TMP "" ${key}_max
    for resource in ${!UPDATE_STARTS[@]}; do
        [[ -n ${UPDATE_ENDS[$resource]:-""} ]] || continue
        info=( $(python3 $SCRIPT_ROOT/../python/datecheck.py \
                    ${UPDATE_STARTS[$resource]} \
                    ${UPDATE_ENDS[$resource]}) )
        ((${#info[@]})) || continue
        t=${info[0]}
        path=${DATA_TMP}/${t//:/_}
        current=$(cat $path/${key}_max)
        ((current<${info[1]})) || continue
        echo ${info[1]} > $path/${key}_max
    done
    create_csv $CSV_PATH $DATA_TMP
}

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv

e1="^[0-9-]+ ([0-9:]+:[0-9:]+[0-9:]+)\.[0-9]+ [0-9]+ .+ \[-\] Creating load balancer '([a-z0-9-]+)'\.+"
e2='^[0-9-]+ ([0-9:]+{3})\.[0-9]+ [0-9]+ .+ \[(\S+ ?){6}\] Mark ACTIVE in DB for load balancer id: ([a-z0-9-]+)$'
process_log $LOG $data_tmp $csv_path "$e1" "$e2"

write_meta $results_dir time lb-creates
cleanup $data_tmp $csv_path
