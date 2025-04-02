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
    #   DATA_TMP: path to temporary directory used to store data
    #   CSV_PATH: path to output CSV file
    #   rows_expr: regular expression (sed) used to identify rows that contains
    #              at least two results groups; the first is datetime and the
    #              rest map told cols.
    #   cols:      a list of one or more column names. The number of result
    #              groups in rows_expr must be exactly one greater than
    #              this number of columns (since the first grouping is always 
    #              the date).

    (($#>4)) || { echo "ERROR: insufficient args to process_log_tally()"; exit 1; }
    local logfile=$1
    local DATA_TMP=$2
    local CSV_PATH=$3
    local rows_expr="$4"
    shift 4
    local cols=( $@ )
    local catcmd=cat
    local current=
    local path=

    #echo "Searching $logfile (lines=$(wc -l $logfile| cut -d ' ' -f 1))"

    ensure_csv_path $CSV_PATH
    file --mime-type $logfile| grep -q application/gzip && catcmd=zcat

    readarray -t rows<<<$(get_categories $catcmd $logfile "$rows_expr")
    (( ${#rows[@]} )) && [[ -n ${rows[0]} ]] || return 0

    init_dataset $DATA_TMP "" ${cols[@]}
    for entry in "${rows[@]}"; do
        declare -a info=( $entry )
        # round to nearest 10 minutes
        t=${info[0]::4}0
        path=${DATA_TMP}/${t//:/_}
        for ((i=1; i<=${#cols[@]}; i+=1)); do
            current=$(cat $path/${cols[$((i-1))]})
            echo "$((current + 1))" > $path/${cols[$((i-1))]}
        done
    done
    create_csv $CSV_PATH $DATA_TMP
}

