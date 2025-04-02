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

deltas_init_dataset ()
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


process_log_event_deltas ()
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
    #   y_label: y-axis label
    #   cols_expr: regular expression (sed) used to identify columns.
    #              Must identify one result group that matches the column
    #              name.
    #   rows_expr: regular expression (sed) used to identify row.
    #              This expression will typically be the same as cols_expr
    #              but with an $INSERT variable in place of the column
    #              name.
    #   delta_events_expr: regular expression (egrep) used to events between
    #                      the start and end of a sequence.

    (($#==7)) || { echo "ERROR: insufficient args ($#) to process_log_event_deltas()"; exit 1; }
    local logfile=$1
    local data_tmp=$2
    local csv_path=$3
    local y_label=$4
    local cols_expr="$5"
    local rows_expr="$6"
    local delta_events_expr="$7"
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
    file --mime-type $LOG| grep -q application/gzip && CATCMD=zcat || CATCMD=cat

    # get sequence end
    ends=$(mktemp -p $data_tmp)
    get_categories $catcmd $logfile "s/$rows_expr/\0/p" > $ends
    [[ -s $ends ]] || return 0

    # get sequence starts
    starts=$(mktemp -p $data_tmp)
    get_categories $catcmd $logfile "s/$cols_expr/\0/p" > $starts
    [[ -s $starts ]] || return 0

    # line numbers of sequence ends
    declare -n LN_DARRAY_STORE="range_ends"
    declare -n TIMINGS_DARRAY_STORE="range_end_times"
    get_line_numbers "$rows_expr" $ends $LOG
    (( ${#range_ends[@]} )) || return 0

    # line numbers of sequence starts
    declare -n LN_DARRAY_STORE="range_starts"
    declare -n TIMINGS_DARRAY_STORE="range_start_times"
    get_line_numbers "$cols_expr" $starts $LOG
    (( ${#range_starts[@]} )) || return 0

    for resource in ${!range_starts[@]}; do
        start=${range_starts[$resource]}
        [[ ${range_ends[$resource]:-null} = null ]] && continue
        end=${range_ends[$resource]}
        event_deltas[$resource]=$(get_num_matching_lines $start $end "$delta_events_expr" $LOG)
    done

    deltas_init_dataset $y_label $data_tmp ${range_start_times[@]}

    for vm in ${!event_deltas[@]}; do
        # round to nearest 10 minutes
        t=${range_end_times[$vm]::-4}0
        path=${data_tmp}/${t//:/_}
        current=$(cat $path/$y_label)
        delta=${event_deltas[$vm]}
        (($delta > $current)) || continue
        echo $delta > $path/$y_label
    done
    create_csv $csv_path $data_tmp
}
