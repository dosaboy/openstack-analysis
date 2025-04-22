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
    local path

    ((hour<10)) && hour="0$hour"

    if [[ -n $date ]]; then
        # keep date in iso-8601 format
        prefix=${date}T
    fi

    ((min % 10)) && return  0
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

init_dataset_multi_date ()
{
    local label=$1
    local path=$2
    shift 2
    declare -a dates=( $@ )

    # get Y-M-D variants
    declare -A tsdates=()
    for _date in ${dates[@]}; do
        tsdates[$(echo $_date|egrep -o "^([0-9-]+)")]=true
    done

    for tsdate in ${!tsdates[@]}; do
        init_dataset $path "$tsdate" $label
    done
}

cleanup ()
{
    local tmpdir=$1
    local csv_file=$2

    [[ -n $tmpdir ]] || { echo "ERROR: datatmp path ($tmpdir) not set!"; exit 1; }

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
            write_meta $RESULTS_DIR time
            cleanup $DATA_TMP $CSV_PATH
            exit 0
        fi

        rm -f $path
    fi
}

write_meta ()
{
    local dout=$1
    local x_label=$2
    local y_label=${3:-""}
    local plot_type=${4:-bar}  # options: stacked | bar

    outpath=${dout}/meta.yaml
    # if no ylabel and meta already exists, attempt to get existing and update.
    if [[ -z $y_label ]]; then
        if [[ -e $outpath ]]; then
            y_label=$(sed -rn 's/ylabel: (\S+)/\1/p' $outpath)
            [[ -n $y_label ]] || return
        else
            return
        fi
    fi

    echo -e "xlabel: $x_label" > $outpath
    echo -e "ylabel: $y_label" >> $outpath
    echo -e "agent: $AGENT_NAME" >> $outpath
    echo -e "type: $plot_type" >> $outpath
}

get_results_dir ()
{
    local mod_name=
    local script_name=
    local path=

    path=$OUTPUT_PATH/data/$__SCRIPT_MODULE_NAME__/$__SCRIPT_NAME__
    flock $LOCKFILE mkdir -p $path
    echo $path
}

filter_log ()
{
    local path=$1
    local filter="$2"
    local reverse=${3:-false}
    local filtered=
    local cmd=egrep

    file --mime-type $path| grep -q application/gzip && cmd=zegrep
    filtered=$(mktemp -p $DATA_TMP --suffix=-filteredlog)
    if $reverse; then
        $cmd -v "$filter" $path > $filtered
    else
        $cmd "$filter" $path > $filtered
    fi
    echo $filtered
}

skip ()
{
    local reason=${1:-"unknown"}
    echo "INFO: skipping script - reason='$reason'"
    exit 0
}

# Load processors
for processor in ${SCRIPT_ROOT}/lib/processors/*; do
    . $processor
done

SCRIPT_HEADER ()
{
    [[ -z $LOG_NAME_FILTER ]] || [[ $LOG =~ $LOG_NAME_FILTER ]] || exit 0
    . $SCRIPT_ROOT/lib/log_expressions.sh
    export RESULTS_DIR=$(get_results_dir)
    export DATA_TMP=`mktemp -d -p $RESULTS_DIR --suffix=-datatmp`
    export CSV_PATH=$RESULTS_DIR/${HOSTNAME}_$(basename $RESULTS_DIR).csv
}


SCRIPT_FOOTER ()
{
    write_meta $RESULTS_DIR time $Y_LABEL ${PLOT_TYPE:-""}
    cleanup $DATA_TMP $CSV_PATH
}
