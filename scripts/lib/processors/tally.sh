process_log_tally ()
{
    # Description: 
    #   Identify a single column then for every 10 minute window,
    #   tally its occurences.
    #
    #   The resulting csv data will have one y-axis column per
    #   provided column name and a row for every ten minutes of time.
    #
    # Params:
    #   logfile: path to logfile
    #   data_tmp: path to temporary directory used to store data
    #   csv_path: path to output CSV file
    #   rows_expr: regular expression (sed) used to identify rows that contains
    #              two result groups - date and time.
    #   filter_log_module: Apply the default filter of LOG_MODULE to the
    #                      logfile prior to searching.
    #   colname: a single column name used to store the tally value
    #   filter_log_module: Apply the default filter of LOG_MODULE to the
    #                      logfile prior to searching.

    (($#==6)) || { echo "ERROR: insufficient args to process_log_tally()"; exit 1; }
    # Opts
    local logfile=$1
    local data_tmp=$2
    local csv_path=$3
    local rows_expr="$4"
    local filter_log_module=$5
    local colname=$6
    # Vars
    local catcmd=cat
    local current=
    local path=
    local datetime=

    log_debug "searching $logfile (lines=$(wc -l $logfile| cut -d ' ' -f 1))"
    ensure_csv_path $csv_path || return

    if $filter_log_module; then
        log_debug "filtering log using '$LOG_MODULE' (script=$__SCRIPT_NAME__)"
        logfile=$(filter_log $logfile $LOG_MODULE)
    fi

    if [[ -n $USER_FILTER ]]; then
        log_debug "applying user filter to log (script=$__SCRIPT_NAME__)"
        logfile=$(filter_log $logfile "$USER_FILTER" true)
    fi

    file --mime-type $logfile| grep -q application/gzip && catcmd=zcat

    rows_expr="s,$rows_expr,\1T\2,p"
    readarray -t rows<<<$(get_categories $catcmd $logfile "$rows_expr")
    (( ${#rows[@]} )) && [[ -n ${rows[0]} ]] || return 0

    for entry in "${rows[@]}"; do
        declare -a info=( $entry )
        # round to nearest 10 minutes
        datetime=${info[0]::-4}0
        path=${data_tmp}/${datetime//:/_}
        [[ -r $path/$colname ]] || init_dataset $data_tmp ${datetime%T*} $colname
        current=$(cat $path/$colname)
        echo "$((current + 1))" > $path/$colname
    done
    create_csv $csv_path $data_tmp
}

