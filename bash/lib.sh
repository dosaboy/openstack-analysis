#!/bin/bash -u

_init_time ()
{
    local root=$1
    local date=$2
    local hour=$3
    local min=$4
    shift 4
    local columns=( $@ )
    local prefix=""

    ((hour<10)) && hour="0$hour"

    if [[ -n $date ]]; then
        prefix=${date}_
    fi

    ((min % 10)) && return
    ((min == 0)) && min=${min}0
    path=${root}/${prefix}${hour}_${min}
    if ! [[ -d $path ]]; then
        mkdir -p $path;
        for _p in ${columns[@]}; do
            echo 0 > $path/$_p
        done
    fi
}

init_dataset ()
{
    local root=$1
    local date=$2
    shift 2
    local columns=( $@ )

    for h in {0..23}; do
        for m in {0..59}; do
            _init_time $root "$date" $h $m ${columns[@]}
        done
    done
}

cleanup ()
{
    local tmpdir=$1
    local csv_file=$2

    [[ -n $tmpdir ]] || { echo "ERROR!"; exit 1; }

    rm -rf $tmpdir
    [[ -f $csv_file ]] && ls -al $csv_file
    if [[ -f $csv_file ]] && $(egrep -q "datetime,$" $csv_file); then
        rm $csv_file
    fi
}

create_csv ()
{
    local OUT=$1
    local DOUT=$2
    local columns=

    echo -n "datetime," > $OUT
    columns=( $(ls $(ls $DOUT/*/| head -n1| tr -d ':')) )
    echo ${columns[@]}| tr ' ' ',' >> $OUT
    for d in `ls -d $DOUT/{0..9}* 2>/dev/null| sort`; do
        echo -n $(basename $d| tr '_' ':'), >> $OUT
        cat ${d}/*| tr '\n' ','| head -c -1 >> $OUT
        echo "" >> $OUT
    done
}


get_categories ()
{
    local CATCMD=$1
    local LOG=$2
    local EXPR="$3"
    local UNIQUE=${4:-true}

    if $UNIQUE; then
        $CATCMD $LOG| sed -rn "$EXPR"| sort -u
    else
        $CATCMD $LOG| sed -rn "$EXPR"
    fi
}

ensure_csv_path ()
{
    if [[ -e $CSV_PATH ]]; then
        if ! $OVERWRITE_CSV; then
            echo "$CSV_PATH already exists and overwrite=false - skipping"
            exit 0
        fi

        rm -f $CSV_PATH
    fi
}

process_log ()
{
    (($#>=5)) || { echo "ERROR: insufficient args to process_log()"; exit 1; }
    local LOG=$1
    local DATA_TMP=$2
    local CSV_PATH=$3
    local CATEGORY_EXPR1="$4"
    local CATEGORY_EXPR2="$5"
    local CATCMD=cat
    local MAX_JOBS=10
    local NUM_JOBS=0
    local current=

    #echo "Searching $LOG ($(wc -l $LOG))"

    ensure_csv_path
    file --mime-type $LOG| grep -q application/gzip && CATCMD=zcat

    declare -a CATEGORY=( $(get_categories $CATCMD $LOG "$CATEGORY_EXPR1") )
    (( ${#CATEGORY[@]} )) || return

    init_dataset $DATA_TMP "" ${CATEGORY[@]}

    flag=$(mktemp)
    echo "0" > $flag
    for c in ${CATEGORY[@]}; do
        ((NUM_JOBS+=1))
        for t in $($CATCMD $LOG| \
                    sed -rn "$(eval echo \"$CATEGORY_EXPR2\")"); do
            local path=${DATA_TMP}/${t//:/_}
            current=$(cat $path/$c)
            echo $((current+1)) > $path/$c
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


process_log_simple ()
{
    (($#>4)) || { echo "ERROR: insufficient args to process_log_simple()"; exit 1; }
    local LOG=$1
    local DATA_TMP=$2
    local CSV_PATH=$3
    local EXPR1="$4"
    shift 4
    local KEYS=( $@ )
    local CATCMD=cat

    ensure_csv_path
    file --mime-type $LOG| grep -q application/gzip && CATCMD=zcat

    readarray -t rows<<<$(get_categories $CATCMD $LOG "$EXPR1")
    (( ${#rows[@]} )) && [[ -n ${rows[0]} ]] || return

    init_dataset $DATA_TMP "" ${KEYS[@]}
    for entry in "${rows[@]}"; do
        declare -a info=( $entry )
        t=${info[0]}
        path=${DATA_TMP}/${t//:/_}
        for ((i=1; i<=${#KEYS[@]}; i+=1)); do
            echo "${info[$i]}" > $path/${KEYS[$((i-1))]}
        done
    done
    create_csv $CSV_PATH $DATA_TMP
}


process_log_tally ()
{
    (($#>4)) || { echo "ERROR: insufficient args to process_log_simple()"; exit 1; }
    local LOG=$1
    local DATA_TMP=$2
    local CSV_PATH=$3
    local EXPR1="$4"
    shift 4
    local KEYS=( $@ )
    local CATCMD=cat
    local current=

    ensure_csv_path
    file --mime-type $LOG| grep -q application/gzip && CATCMD=zcat

    readarray -t rows<<<$(get_categories $CATCMD $LOG "$EXPR1")
    (( ${#rows[@]} )) && [[ -n ${rows[0]} ]] || return

    init_dataset $DATA_TMP "" ${KEYS[@]}
    for entry in "${rows[@]}"; do
        declare -a info=( $entry )
        t=${info[0]}
        path=${DATA_TMP}/${t//:/_}
        for ((i=1; i<=${#KEYS[@]}; i+=1)); do
            current=$(cat $path/${KEYS[$((i-1))]})
            echo "$((current + 1))" > $path/${KEYS[$((i-1))]}
        done
    done
    create_csv $CSV_PATH $DATA_TMP
}


write_meta ()
{
    local DOUT=$1
    local X_LABEL=$2
    local Y_LABEL=$3

    echo -e "xlabel: $X_LABEL\nylabel: $Y_LABEL\n" > ${DOUT}/meta.yaml
}

get_script_name ()
{
    basename $0| sed -r 's/[0-9]+-(.+)\.sh/\1/'| tr '-' '_'
}

get_results_dir ()
{
    local mod_name=
    local script_name=
    local path=

    mod_name=$(basename $(dirname $0))
    script_name=$(get_script_name)
    path=results_data/${mod_name}/$script_name

    mkdir -p $path
    echo $path
}
