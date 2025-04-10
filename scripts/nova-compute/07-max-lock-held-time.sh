#!/bin/bash -eu
#
# Description: capture amount of time nova-compute locks are held for.
#
. $SCRIPT_ROOT/lib/helpers.sh


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
    # OVERRIDE DEFAULT PROCESSOR

    local LOG=$1
    local DATA_TMP=$2
    local CSV_PATH=$3
    local CATEGORY_EXPR1="$4"
    local CATEGORY_EXPR2="$5"
    local CATCMD
    local MAX_JOBS=10
    local NUM_JOBS=0

    ensure_csv_path $CSV_PATH
    file --mime-type $LOG| grep -q application/gzip && CATCMD=zcat || CATCMD=cat

    readarray -t CATEGORY<<<$($CATCMD $LOG| sed -rn "$CATEGORY_EXPR1"| sort -u)
    (( ${#CATEGORY[@]} )) && [[ -n ${CATEGORY[0]} ]] || return 0

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
            # round to nearest 10 minutes
            t=${t[0]::4}0
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

SCRIPT_HEADER oslo_concurrency.lockutils

col_expr="s/$EXPR_LOG_DATE [0-9]+ \w+ $LOG_MODULE .+ Lock \\\"([a-z0-9_-]+)\\\" .+ :: held ([0-9]+).[0-9]+s.+/\1 \2/p"
row_expr="s/$EXPR_LOG_DATE_GROUP_TIME [0-9]+ \w+ $LOG_MODULE .+ Lock \\\"\$name\\\" .+ :: held [0-9]+.[0-9]+s.+/\1/p"
process_log $(filter_log $LOG $LOG_MODULE) $DATA_TMP $CSV_PATH "$col_expr" "$row_expr"

SCRIPT_FOOTER max-lock-held-time
