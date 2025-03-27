get_timings ()
{
    # Description:
    #   Go through each line, apply the sed search and if a match is found
    #   store the time (result group 1) using the resource (result group 2) as
    #   the key.

    local sed_expr="$1"
    local path=$2
    # NOTE: uses global TIMINGS_DARRAY_STORE to store results

    declare -A dups=()
    while read line; do
        info=( $(echo "$line"| sed -rn "s/$sed_expr/\1T\2 \3/p") )
        ((${#info[@]})) || continue
        timestamp=${info[0]}
        resource=${info[1]}
        if [[ ${TIMINGS_DARRAY_STORE[$resource]:-null} != null ]]; then
            if [[ ${dups[$resource]:-null} != null ]]; then
                dups[$resource]=$(( ${dups[$resource]} + 1))
            else
                dups[$resource]=1
            fi
        fi
        TIMINGS_DARRAY_STORE[$resource]=$timestamp
    done <$path

    for res in ${!dups[@]}; do
        ((${dups[$res]}>1)) || continue
        echo "WARNING: resource $res found more than once (${dups[$res]}) - final occurence recorded"
    done
}

process_log_deltas ()
{
    # Description:
    #   Identify start and end times for an event using a search
    #   expression for each then calculate the time delta and
    #   save the maximum occurence per 10 minute window.
    #
    #   The resulting csv data will have one y-axis column
    #   and a row for every ten minutes of time.
    #
    # Params:
    #   logfile: path to logfile
    #   DATA_TMP: path to temporary directory used to store data
    #   CSV_PATH: path to output CSV file
    #   cols_expr: regular expression (sed) used to identify columns.
    #              Must identify one result group that matches the column
    #              name.
    #   rows_expr: regular expression (sed) used to identify row.
    #              This expression will typically be the same as cols_expr
    #              but with an $INSERT variable in place of the column
    #              name.

    (($#==5)) || { echo "ERROR: insufficient args ($#) to process_log_deltas()"; exit 1; }
    local logfile=$1
    local DATA_TMP=$2
    local CSV_PATH=$3
    local cols_expr="$4"
    local rows_expr="$5"
    local catcmd=cat
    local max_jobs=10
    local num_jobs=0
    local label=
    local current=
    local path=
    declare -A tsdates=()
    declare -A range_starts=()
    declare -A range_ends=()

    #echo "Searching $logfile (lines=$(wc -l $logfile| cut -d ' ' -f 1))"

    ensure_csv_path $CSV_PATH
    file --mime-type $logfile| grep -q application/gzip && catcmd=zcat

    starts=$(mktemp -p $DATA_TMP)
    get_categories $catcmd $logfile "s/$cols_expr/\0/p" > $starts
    [[ -s $starts ]] || return

    ends=$(mktemp -p $DATA_TMP)
    get_categories $catcmd $logfile "s/$rows_expr/\0/p" > $ends
    [[ -s $ends ]] || return

    declare -n TIMINGS_DARRAY_STORE="range_starts"
    get_timings "$cols_expr" $starts
    (( ${#range_starts[@]} )) || return

    declare -n TIMINGS_DARRAY_STORE="range_ends"
    get_timings "$rows_expr" $ends
    (( ${#range_ends[@]} )) || return

    # get Y-M-D variants
    declare -A tsdates=()
    for _date in ${range_starts[@]}; do
        _date=$(echo $_date|egrep -o "^([0-9-]+)")
        tsdates[$_date]=true
    done

    label=$(get_script_name)_deltas
    for tsdate in ${!tsdates[@]}; do
        init_dataset $DATA_TMP "$tsdate" $label
    done
    for resource in ${!range_starts[@]}; do
        [[ -n ${range_ends[$resource]:-""} ]] || continue
        info=( $(python3 $SCRIPT_ROOT/../python/datecheck.py \
                    ${range_starts[$resource]} \
                    ${range_ends[$resource]}) )
        ((${#info[@]})) || continue
        t=${info[0]}
        path=${DATA_TMP}/${t//:/_}
        current=$(cat $path/$label)
        ((current<${info[1]})) || continue
        echo ${info[1]} > $path/$label
    done
    create_csv $CSV_PATH $DATA_TMP
}
