get_line_numbers ()
{
    # Description:
    #   Go through each line, apply the sed search and if a match is found
    #   store the time (result group 1) using the resource (result group 2) as
    #   the key. Also store the line number where the match was found.

    local sed_expr="$1"
    local path=$2
    local logfile=$3

    # NOTE: uses globals to store results:
    #   - LN_DARRAY_STORE
    #   - TIMINGS_DARRAY_STORE

    while read line; do
        info=( $(echo "$line"| sed -rn "s/$sed_expr/\1T\2 \3/p") )
        ((${#info[@]})) || continue
        resource=${info[1]}
        TIMINGS_DARRAY_STORE[$resource]=${info[0]}
        LN_DARRAY_STORE[$resource]=$(grep -nF "$line" $logfile| cut -d ':' -f 1)
    done <$path
}

get_num_matching_lines ()
{
    # Description:
    #   get number of lines matching expr between start and end.

    local ln_start=$1
    local ln_end=$2
    local expr="$3"
    local logfile=$4

    tail -n +$ln_start $logfile| head -n $(($ln_end - $ln_start))| egrep "$expr" | wc -l
}

process_log_event_deltas ()
{
    # Description:
    #   Identify start and end times for an event using a search
    #   expression then using a third expression, counts the
    #   number of times it matches between start and end and
    #   save per 10 minute window.
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
    #   delta_events_expr: regular expression (egrep) used to events between
    #                      the start and end of a sequence.
    #   filter_log_module: Apply the default filter of LOG_MODULE to the
    #                      logfile prior to searching.

    (($#==7)) || { echo "ERROR: insufficient args ($#) to process_log_event_deltas()"; exit 1; }
    # Opts
    local logfile=$1
    local data_tmp=$2
    local csv_path=$3
    local seq_start_expr="$4"
    local seq_end_expr="$5"
    local delta_events_expr="$6"
    local filter_log_module=$7
    # Vars
    local catcmd=cat
    local max_jobs=10
    local num_jobs=0
    local current=
    local path=
    local resource=
    local start=
    local end=
    local delta=
    declare -A range_starts=()
    declare -A range_ends=()
    declare -A event_deltas=()
    declare -A range_end_times=()
    declare -A range_start_times=()

    ensure_csv_path $csv_path

    if $filter_log_module; then
        echo "INFO: filtering log using '$LOG_MODULE' (script=$__SCRIPT_NAME__)"
        logfile=$(filter_log $logfile $LOG_MODULE)
    fi

    file --mime-type $logfile| grep -q application/gzip && catcmd=zcat

    # get sequence end
    ends=$(mktemp -p $data_tmp)
    get_categories $catcmd $logfile "s/$seq_end_expr/\0/p" > $ends
    [[ -s $ends ]] || return 0

    # get sequence starts
    starts=$(mktemp -p $data_tmp)
    get_categories $catcmd $logfile "s/$seq_start_expr/\0/p" > $starts
    [[ -s $starts ]] || return 0

    # line numbers of sequence ends
    declare -n LN_DARRAY_STORE="range_ends"
    declare -n TIMINGS_DARRAY_STORE="range_end_times"
    get_line_numbers "$seq_end_expr" $ends $logfile
    (( ${#range_ends[@]} )) || return 0

    # line numbers of sequence starts
    declare -n LN_DARRAY_STORE="range_starts"
    declare -n TIMINGS_DARRAY_STORE="range_start_times"
    get_line_numbers "$seq_start_expr" $starts $logfile
    (( ${#range_starts[@]} )) || return 0

    for resource in ${!range_starts[@]}; do
        start=${range_starts[$resource]}
        [[ ${range_ends[$resource]:-null} = null ]] && continue
        end=${range_ends[$resource]}
        event_deltas[$resource]=$(get_num_matching_lines $start $end "$delta_events_expr" $logfile)
    done

    init_dataset_multi_date $Y_LABEL $data_tmp ${range_start_times[@]}

    for vm in ${!event_deltas[@]}; do
        # round to nearest 10 minutes
        t=${range_end_times[$vm]::-4}0
        path=${data_tmp}/${t//:/_}
        current=$(cat $path/$Y_LABEL)
        delta=${event_deltas[$vm]}
        (($delta > $current)) || continue
        echo $delta > $path/$Y_LABEL
    done
    create_csv $csv_path $data_tmp
}
