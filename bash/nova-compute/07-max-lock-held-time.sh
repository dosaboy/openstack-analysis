#!/bin/bash -eu
#
# Description: capture amount of time nova-compute locks are held for.
#
. $SCRIPT_ROOT/lib.sh

is_uuid ()
{
    if $(echo "$1"| egrep -q "([0-9a-z]){32}"); then
        return 0
    elif $(echo "$1"| egrep -q "([0-9a-z-]){36}"); then
        return 0
    else
        return 1
    fi
}


process_log ()
{
    local LOG=$1
    local DATA_TMP=$2
    local CSV_PATH=$3
    local CATEGORY_EXPR1="$4"
    local CATEGORY_EXPR2="$5"
    local CATCMD
    local MAX_JOBS=10
    local NUM_JOBS=0

    ensure_csv_path
    file --mime-type $LOG| grep -q application/gzip && CATCMD=zcat || CATCMD=cat

    readarray -t CATEGORY<<<$($CATCMD $LOG| sed -rn "$CATEGORY_EXPR1"| sort -u)
    (( ${#CATEGORY[@]} )) && [[ -n ${CATEGORY[0]} ]] || return

    TIME_LIMIT_MIN=30

    RESOURCE_TAG=NOVA_RESOURCES

    declare -A deduped=()
    # Aggregate all resource locks into a single entry so that the others are easier to distinguish
    declare -A _filtered[$RESOURCE_TAG]=0
    for c in "${CATEGORY[@]}"; do
        declare -a _c=( $c )
        name=${_c[0]}
        deduped[$name]=0
        time=${_c[1]}
        (($time>=$TIME_LIMIT_MIN)) || continue
        if ! is_uuid $name; then
            _filtered[$name]=0
        fi
    done

    init_dataset $DATA_TMP "" ${!_filtered[@]}

    local current=0
    flag=$(mktemp)
    echo "0" > $flag
    for c in "${CATEGORY[@]}"; do
        declare -a _c=( $c )
        name=${_c[0]}
        time=${_c[1]}
        (($time>=$TIME_LIMIT_MIN)) || continue

        ((${deduped[$name]}==0)) || continue
        deduped[$name]=1

        ((NUM_JOBS+=1))
        for t in $($CATCMD $LOG| sed -rn "$(eval echo \"$CATEGORY_EXPR2\")"); do
            local path=${DATA_TMP}/${t//:/_}
            if is_uuid $name; then
                name=$RESOURCE_TAG
            fi
            current=$(cat $path/$name)
            ((time > current)) || continue
            echo $time > $path/$name
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
module=oslo_concurrency.lockutils
e1="s/[0-9-]+ [0-9:]+:[0-9][0-9]:[0-9]+.[0-9]+ [0-9]+ \w+ $module .+ Lock \\\"([a-z0-9_-]+)\\\" .+ :: held ([0-9]+).[0-9]+s.+/\1 \2/p"
e2="s/[0-9-]+ ([0-9:]+:[0-9])[0-9]:[0-9]+.[0-9]+ [0-9]+ \w+ $module .+ Lock \\\"\$name\\\" .+ :: held [0-9]+.[0-9]+s.+/\10/p"

process_log $(filter_log $LOG $module) $data_tmp $csv_path "$e1" "$e2"
write_meta $results_dir time lock-held-time
cleanup $data_tmp $csv_path
