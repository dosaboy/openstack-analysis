#!/bin/bash -eu
#
# Description: capture time taken to allocate network resources for new vm.
#
. $SCRIPT_ROOT/lib.sh
SCRIPT_NAME=$(basename $0| sed -r 's/[0-9]+-(.+)\.sh/\1/'| tr '-' '_')
RESULTS_DIR=results_data/$SCRIPT_NAME
mkdir -p $RESULTS_DIR

process_log ()
{
    local LOG=$1
    local DATA_TMP=$2
    local CSV_PATH=$3
    local EXPR1="$4"
    local EXPR2="$5"
    local CATCMD
    local MAX_JOBS=10
    local NUM_JOBS=0

    ensure_csv_path
    file --mime-type $LOG| grep -q application/gzip && CATCMD=zcat || CATCMD=cat

    # NOTE: exclude service thread
    readarray -t starts<<<$(get_categories $CATCMD $LOG "$EXPR1"| grep -v "\- - - - -]")
    (( ${#starts[@]} )) && [[ -n ${starts[0]} ]] || return

    # NOTE: exclude service thread
    readarray -t ends<<<$(get_categories $CATCMD $LOG "$EXPR2"| grep -v "\- - - - -]")
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

    local key=$SCRIPT_NAME
    init_dataset $DATA_TMP "" ${key}_max

    local current=
    local path=

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
    create_csv $CSV_PATH $DATA_TMP
}

data_tmp=`mktemp -d -p $RESULTS_DIR`
csv_path=$RESULTS_DIR/${HOSTNAME}_$(basename $RESULTS_DIR).csv
module=os_vif
preamble_common="[0-9-]+ ([0-9:]+:[0-9])[0-9]:[0-9]+.[0-9]+ [0-9]+ \w+ $module \[req-[0-9a-z-]+ ([0-9a-z-]+) ([0-9a-z-]+) .+\]"
e1="s/$preamble_common Plugging vif .+/\0/p"
e2="s/$preamble_common Successfully plugged vif .+/\0/p"

FILTERED=$(mktemp -p $data_tmp)
grep $module $LOG > $FILTERED
process_log $FILTERED $data_tmp $csv_path "$e1" "$e2"

write_meta $RESULTS_DIR time os-vif-plug-time
cleanup $data_tmp $csv_path
