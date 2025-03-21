#!/bin/bash -eu
#
# Description: capture max amount of time taken to build instances.
#
. $SCRIPT_ROOT/lib.sh

process_log ()
{
    local LOG=$1
    local DATA_TMP=$2
    local CSV_PATH=$3
    local CATCMD
    local MAX_JOBS=10
    local NUM_JOBS=0
    local current=
    local path=

    ensure_csv_path
    file --mime-type $LOG| grep -q application/gzip && CATCMD=zcat || CATCMD=cat

    declare -a CATEGORY=( $($CATCMD $LOG| sed -rn 's/[0-9-]+ [0-9:.]+ [0-9]+ \w+ nova.compute.manager \[req-[0-9a-z-]+ ([0-9a-z-]+) ([0-9a-z-]+) .+\] .+ Took ([0-9]+).[0-9]+ seconds to build instance./\2/p'| sort -u) )
    (( ${#CATEGORY[@]} )) || return

    init_dataset $DATA_TMP "" ${CATEGORY[@]}

    flag=$(mktemp)
    echo "0" > $flag
    for c in ${CATEGORY[@]}; do
        ((NUM_JOBS+=1))
        readarray -t ret<<<$($CATCMD $LOG| sed -rn "s/([0-9-]+) ([0-9:]+:[0-9])[0-9]:[0-9]+.[0-9]+ [0-9]+ \w+ nova.compute.manager \[req-[0-9a-z-]+ [0-9a-z-]+ $c .+\] Took ([0-9]+).[0-9]+ seconds to build instance./\20 \3/p")
        for t in "${ret[@]}"; do
            declare -a tt=( $t )
            path=${DATA_TMP}/${tt[0]//:/_}
            current=$(cat $path/$c)
            # Store max build time
            if ((${tt[1]} > $current)); then
                echo ${tt[1]} > $path/$c
            fi
            echo "1" > $flag
        done &
        if ((NUM_JOBS==MAX_JOBS)); then
            wait
            NUM_JOBS=0
        fi
    done
    wait
    (($(cat $flag)==1)) && create_csv $CSV_PATH $DATA_TMP
    rm $flag
}

results_dir=$(get_results_dir)
data_tmp=`mktemp -d -p $results_dir`
csv_path=$results_dir/${HOSTNAME}_$(basename $results_dir).csv
module=nova.compute.manager

FILTERED=$(mktemp -p $data_tmp)
grep $module $LOG > $FILTERED
process_log $FILTERED $data_tmp $csv_path

write_meta $results_dir time instance-build-time
cleanup $data_tmp $csv_path
