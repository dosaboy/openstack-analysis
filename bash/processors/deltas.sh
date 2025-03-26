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
    #   cols_expr: regular expression (sed) used to identify columns.
    #              Must identify one result group that matches the column
    #              name.
    #   rows_expr: regular expression (sed) used to identify row.
    #              This expression will typically be the same as cols_expr
    #              but with an $INSERT variable in place of the column
    #              name.

    (($#==5)) || { echo "ERROR: insufficient args ($#) to process_log_deltas()"; exit 1; }
    local logfile=$1
    local data_tmp=$2
    local csv_path=$3
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

    ensure_csv_path $csv_path
    file --mime-type $logfile| grep -q application/gzip && catcmd=zcat

    readarray -t starts<<<$(get_categories $catcmd $logfile "s/$cols_expr/\0/p")
    (( ${#starts[@]} )) && [[ -n ${starts[0]} ]] || return

    readarray -t ends<<<$(get_categories $catcmd $logfile "s/$rows_expr/\0/p")
    (( ${#ends[@]} )) && [[ -n ${ends[0]} ]] || return

    for line in "${starts[@]}"; do
        info=( $(echo "$line"| sed -rn "s/$cols_expr/\1T\2 \3/p") )
        start=${info[0]}
        resource=${info[1]}
        [[ ${range_starts[$resource]:-null} = null ]] || echo "WARNING: resource $resource found more than once - overwriting"
        range_starts[$resource]=$start
        _date=$(echo $start|egrep -o "^([0-9-]+)")
        tsdates[$_date]=true
    done

    for line in "${ends[@]}"; do
        info=( $(echo "$line"| sed -rn "s/$rows_expr/\1T\2 \3/p") )
        ends=${info[0]}
        resource=${info[1]}
        [[ ${range_ends[$resource]:-null} = null ]] || echo "WARNING: resource $resource end found more than once - overwriting"
        range_ends[$resource]=$ends
    done

    label=$(get_script_name)_deltas
    for tsdate in ${!tsdates[@]}; do
        init_dataset $data_tmp "$tsdate" $label
    done
    for resource in ${!range_starts[@]}; do
        [[ -n ${range_ends[$resource]:-""} ]] || continue
        info=( $(python3 $SCRIPT_ROOT/../python/datecheck.py \
                    ${range_starts[$resource]} \
                    ${range_ends[$resource]}) )
        ((${#info[@]})) || continue
        t=${info[0]}
        path=${data_tmp}/${t//:/_}
        current=$(cat $path/$label)
        ((current<${info[1]})) || continue
        echo ${info[1]} > $path/$label
    done
    create_csv $csv_path $data_tmp
}
