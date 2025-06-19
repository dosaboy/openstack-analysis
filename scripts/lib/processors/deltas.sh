get_timings ()
{
    # Description:
    #   Go through each line, apply the sed search and if a match is found
    #   store the time (result group 1) using the resource (result group 2) as
    #   the key.

    local sed_expr="$1"
    local path=$2
    local line_number_for_resource=$3

    # NOTE: uses globals to store results:
    #   - TIMINGS_DARRAY_STORE

    declare -A dups=()
    ln=0
    while read line; do
        ((ln++))
        info=( $(echo "$line"| sed -rn "s/$sed_expr/\1T\2 \3/p") )
        ((${#info[@]})) || continue
        timestamp=${info[0]}
        $line_number_for_resource && resource=$ln || resource=${info[1]}
        if [[ ${TIMINGS_DARRAY_STORE[$resource]:-null} != null ]]; then
            if [[ ${dups[$resource]:-null} != null ]]; then
                dups[$resource]=$(( ${dups[$resource]} + 1))
            else
                dups[$resource]=1
            fi
        else
            # Only store the first occurence but we also log how many dups
            # there are.
            TIMINGS_DARRAY_STORE[$resource]=$timestamp
        fi
    done <$path

    for res in ${!dups[@]}; do
        ((${dups[$res]}>1)) || continue
        echo "WARNING: resource $res found more than once (${dups[$res]}) - first occurence recorded"
    done
}

check_delta ()
{
    local _id=$1
    local start_date="$2"
    local end_date="$3"
    local data_tmp=$4
    local multicol=$5
    local y_label=$6
    # vars
    local info
    local path
    local current

    info=( $(python3 $SCRIPT_ROOT/../python/datecheck.py \
            $start_date $end_date) )
    ((${#info[@]})) || return

    t=${info[0]}
    path=${data_tmp}/${t//:/_}
    if $multicol; then
        y_label=$(echo $_id| sed -rn "s/(.+)-${EXPR_UUID}/\1/p")
        [[ -r $path/$y_label ]] || init_dataset $data_tmp ${start_date%T*} $y_label
    fi
    current=$(cat $path/$y_label)
    if ((current<${info[1]})); then
        echo ${info[1]} > $path/$y_label
    fi
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
    #   multicol: Group values by resource name (with uuid suffix removed).
    #   no_resource_id: Set to true if there is no resource id to identify events.

    (($#>=6 && $#<=8)) || { echo "ERROR: insufficient args ($#) to process_log_deltas()"; exit 1; }
    # Opts
    local logfile=$1
    local data_tmp=$2
    local csv_path=$3
    local seq_start_expr="$4"
    local seq_end_expr="$5"
    local filter_log_module=$6
    local multicol=${7:-false}
    local no_resource_id=${8:-false}
    # Vars
    local catcmd=cat
    local max_jobs=10
    local num_jobs=0
    local current=
    local path=
    declare -A range_starts=()
    declare -A range_ends=()
    local end_date=
    local start_date=
    local start_date_offset=0
    local end_date_offset=0
    local indexes=()
    y_label=${__SCRIPT_NAME__}_deltas

    log_debug "searching $logfile (lines=$(wc -l $logfile| cut -d ' ' -f 1))"
    ensure_csv_path $csv_path || return

    if $filter_log_module; then
        log_debug "filtering log using '$LOG_MODULE' (script=$__SCRIPT_NAME__)"
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
    get_timings "$seq_start_expr" $starts $no_resource_id
    (( ${#range_starts[@]} )) || return 0

    declare -n TIMINGS_DARRAY_STORE="range_ends"
    get_timings "$seq_end_expr" $ends $no_resource_id
    (( ${#range_ends[@]} )) || return 0

    $multicol || init_dataset_multi_date $y_label $data_tmp ${range_starts[@]}

    indexes=( ${!range_starts[@]} )
    if $no_resource_id; then
        readarray -t indexes<<<$(echo ${indexes[@]}| tr ' ' '\n'| sort -n)
    fi

    for _id in ${indexes[@]}; do
        if $no_resource_id; then
            start_date=${range_starts[$((_id + start_date_offset))]:-""}
            end_date=${range_ends[$((_id + end_date_offset))]:-""}
        else
            start_date=${range_starts[$_id]:-""}
            end_date=${range_ends[$_id]:-""}
        fi

        if [[ -z $end_date ]]; then
            continue
        fi

        # If not grouping results by resource id (and using line numbers
        # instead) we are prone to incomplete sequences messing up ordering so
        # we check for that here.
        if $no_resource_id; then
            next_start=${range_starts[$((_id + start_date_offset + 1))]:-"__end__"}
            # Check for an incomplete sequence where next start is before current
            # end.
            if [[ $next_start != "__end__" ]]; then
                if ! $(python3 $SCRIPT_ROOT/../python/date_assert_range_valid.py \
                        $end_date $next_start); then
                    echo "DEBUG: skipping incomplete sequence at start=$start_date"
                    ((start_date_offset++))
                    continue
                fi
            fi

            # Check for an incomplete sequence where end is before start.
            while ! $(python3 $SCRIPT_ROOT/../python/date_assert_range_valid.py \
                    $start_date $end_date); do
                echo "DEBUG: skipping sequence end with no start at $end_date"
                ((end_date_offset++))
                end_id=$(($_id + $end_date_offset))
                end_date=${range_ends[$end_id]:-""}
            done

        fi

        check_delta $_id $start_date $end_date $data_tmp $multicol $y_label
    done
    create_csv $csv_path $data_tmp
}
