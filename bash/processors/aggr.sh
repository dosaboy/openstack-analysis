process_log_aggr ()
{
    # Description: 
    #   Identify one more resources/columns then for each get
    #   values within a 10 minute window and add/aggregate
    #   them.
    #
    #   The resulting csv data will have one y-axis column per
    #   resource and a row for every ten minutes of time.
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

    (($#==5)) || { echo "ERROR: insufficient args ($#) to process_log_aggr()"; exit 1; }
    local logfile=$1
    local DATA_TMP=$2
    local CSV_PATH=$3
    local cols_expr="$4"
    local rows_expr="$5"
    local catcmd=cat
    local max_jobs=10
    local num_jobs=0
    local current=
    local path=

    #echo "Searching $logfile (lines=$(wc -l $logfile| cut -d ' ' -f 1))"

    ensure_csv_path $CSV_PATH
    file --mime-type $logfile| grep -q application/gzip && catcmd=zcat

    declare -a cols=( $(get_categories $catcmd $logfile "$cols_expr") )
    (( ${#cols[@]} )) && [[ -n ${cols[0]} ]] || return

    init_dataset $DATA_TMP "" ${cols[@]}
    flag=$(mktemp)
    echo "0" > $flag
    for c in ${cols[@]}; do
        ((num_jobs+=1))
        INSERT=$c
        readarray -t rows<<<$($catcmd $logfile| sed -rn "$(eval echo \"$rows_expr\")")
        (( ${#rows[@]} )) && [[ -n ${rows[0]} ]] || continue
        for row in "${rows[@]}"; do
            declare -a split=( $row )
            # round to nearest 10 minutes
            t=${split[0]::4}0
            path=${DATA_TMP}/${t//:/_}
            current=$(cat $path/$c)
            echo $((current+1)) > $path/$c
            echo "1" > $flag
        done &
        if ((num_jobs==max_jobs)); then
            wait
            num_jobs=0
        fi
    done
    wait
    (($(cat $flag)==1)) && create_csv $CSV_PATH $DATA_TMP
    rm $flag
}

