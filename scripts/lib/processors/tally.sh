process_log_tally ()
{
    # Description: 
    #   Identify rows that match an event where the result can
    #   contain one or more columns as provided. A tally is then
    #   created for the number of times that event occurs per 10
    #   minute window.
    #
    #   The resulting csv data will have one y-axis column per
    #   provided column name and a row for every ten minutes of time.
    #
    # Params:
    #   logfile: path to logfile
    #   data_tmp: path to temporary directory used to store data
    #   csv_path: path to output CSV file
    #   rows_expr: regular expression (sed) used to identify rows that contains
    #              at least two results groups; the first is datetime and the
    #              rest map told cols.
    #   filter_log_module: Apply the default filter of LOG_MODULE to the
    #                      logfile prior to searching.
    #   cols:      a list of one or more column names. The number of result
    #              groups in rows_expr must be exactly one greater than
    #              this number of columns (since the first grouping is always 
    #              the date).

    (($#>5)) || { echo "ERROR: insufficient args to process_log_tally()"; exit 1; }
    local logfile=$1
    local data_tmp=$2
    local csv_path=$3
    local rows_expr="$4"
    local filter_log_module=$5
    shift 5
    local cols=( $@ )
    local catcmd=cat
    local current=
    local path=

    #echo "Searching $logfile (lines=$(wc -l $logfile| cut -d ' ' -f 1))"

    ensure_csv_path $csv_path

    if $filter_log_module; then
        echo "INFO: filtering log using '$LOG_MODULE' (script=$(get_script_name))"
        logfile=$(filter_log $logfile $LOG_MODULE)
    fi

    file --mime-type $logfile| grep -q application/gzip && catcmd=zcat

    readarray -t rows<<<$(get_categories $catcmd $logfile "$rows_expr")
    (( ${#rows[@]} )) && [[ -n ${rows[0]} ]] || return 0

    init_dataset $data_tmp "" ${cols[@]}
    for entry in "${rows[@]}"; do
        declare -a info=( $entry )
        # round to nearest 10 minutes
        t=${info[0]::4}0
        path=${data_tmp}/${t//:/_}
        for ((i=1; i<=${#cols[@]}; i+=1)); do
            current=$(cat $path/${cols[$((i-1))]})
            echo "$((current + 1))" > $path/${cols[$((i-1))]}
        done
    done
    create_csv $csv_path $data_tmp
}

