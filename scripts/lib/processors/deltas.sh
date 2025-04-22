get_timings ()
{
    # Description:
    #   Go through each line, apply the sed search and if a match is found
    #   store the time (result group 1) using the resource (result group 2) as
    #   the key.

    local sed_expr="$1"
    local path=$2

    # NOTE: uses globals to store results:
    #   - TIMINGS_DARRAY_STORE

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
    #   data_tmp: path to temporary directory used to store data
    #   csv_path: path to output CSV file
    #   seq_start_expr: regular expression (sed) used to identify the start of
    #                   the delta sequence. Must identify three result groups;
    #                   first is date, second is time and third is a unique id
    #                   used to group results.
    #   seq_end_expr: regular expression (sed) used used to identify the end of
    #                 the delta sequence. Must identify three result groups;
    #                 first is date, second is time and third is a unique id
    #                 used to group results.
    #   filter_log_module: Apply the default filter of LOG_MODULE to the
    #                      logfile prior to searching.

    (($#==6)) || { echo "ERROR: insufficient args ($#) to process_log_deltas()"; exit 1; }
    local logfile=$1
    local data_tmp=$2
    local csv_path=$3
    local seq_start_expr="$4"
    local seq_end_expr="$5"
    local filter_log_module=$6
    local catcmd=cat
    local max_jobs=10
    local num_jobs=0
    local current=
    local path=
    declare -A range_starts=()
    declare -A range_ends=()
    y_label=$(get_script_name)_deltas

    #echo "Searching $logfile (lines=$(wc -l $logfile| cut -d ' ' -f 1))"

    ensure_csv_path $csv_path

    if $filter_log_module; then
        echo "INFO: filtering log using '$LOG_MODULE' (script=$(get_script_name))"
        logfile=$(filter_log $logfile $LOG_MODULE)
    fi

    file --mime-type $logfile| grep -q application/gzip && catcmd=zcat

    starts=$(mktemp -p $data_tmp)
    get_categories $catcmd $logfile "s/$seq_start_expr/\0/p" > $starts
    [[ -s $starts ]] || return 0

    ends=$(mktemp -p $data_tmp)
    get_categories $catcmd $logfile "s/$seq_end_expr/\0/p" > $ends
    [[ -s $ends ]] || return 0

    declare -n TIMINGS_DARRAY_STORE="range_starts"
    get_timings "$seq_start_expr" $starts
    (( ${#range_starts[@]} )) || return 0

    declare -n TIMINGS_DARRAY_STORE="range_ends"
    get_timings "$seq_end_expr" $ends
    (( ${#range_ends[@]} )) || return 0

    init_dataset_multi_date $y_label $data_tmp ${range_starts[@]}

    for resource in ${!range_starts[@]}; do
        [[ -n ${range_ends[$resource]:-""} ]] || continue
        info=( $(python3 $SCRIPT_ROOT/../python/datecheck.py \
                    ${range_starts[$resource]} \
                    ${range_ends[$resource]}) )
        ((${#info[@]})) || continue
        t=${info[0]}
        path=${data_tmp}/${t//:/_}
        current=$(cat $path/$y_label)
        ((current<${info[1]})) || continue
        echo ${info[1]} > $path/$y_label
    done
    create_csv $csv_path $data_tmp
}
