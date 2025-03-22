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
    local path=$1

    if [[ -e $path ]]; then
        if ! $OVERWRITE_CSV; then
            echo "$path already exists and overwrite=false - skipping"
            exit 0
        fi

        rm -f $path
    fi
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
    path=$OUTPUT_PATH/data/$mod_name/$script_name

    mkdir -p $path
    echo $path
}

filter_log ()
{
    local path=$1
    local filter="$2"
    local filtered=
    local cmd=grep

    file --mime-type $path| grep -q application/gzip && cmd=zgrep
    filtered=$(mktemp -p $data_tmp)
    $cmd "$filter" $path > $filtered
    echo $filtered
}

# Load processors
for processor in ${SCRIPT_ROOT}/processors/*; do
    . $processor
done
