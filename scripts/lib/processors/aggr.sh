process_log_aggr ()
{
    # Description: 
    #   Identify one more resources/columns then for every 10 minute window,
    #   tally the occurence of each resource OR optionally save theie value.
    #   The default tally behaviour is used if the search results contain a
    #   single group (time) and if there is a second group that is used as the
    #   value to save.
    #
    #   The resulting csv data will have one y-axis column per
    #   resource and a row for every ten minutes of time.
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
    #   filter_log_module: Apply the default filter of LOG_MODULE to the
    #                      logfile prior to searching.

    (($#==6)) || { echo "ERROR: insufficient args ($#) to process_log_aggr()"; exit 1; }
    local logfile=$1
    local data_tmp=$2
    local csv_path=$3
    local cols_expr="$4"
    local rows_expr="$5"
    local filter_log_module=$6
    local catcmd=cat
    local max_jobs=10
    local num_jobs=0
    local current=
    local path=

    #echo "Searching $logfile (lines=$(wc -l $logfile| cut -d ' ' -f 1))"

    ensure_csv_path $csv_path

    if $filter_log_module; then
        echo "INFO: filtering log using '$LOG_MODULE' (script=$(get_script_name))"
        logfile=$(filter_log $logfile $LOG_MODULE)
    fi

    file --mime-type $logfile| grep -q application/gzip && catcmd=zcat

    declare -a cols=( $(get_categories $catcmd $logfile "$cols_expr") )
    (( ${#cols[@]} )) && [[ -n ${cols[0]} ]] || return 0

    init_dataset $data_tmp "" ${cols[@]}
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
            path=${data_tmp}/${t//:/_}
            if ((${#split[@]} > 1)); then
                # if more than one result group exists use the second group as the value
                echo ${split[1]}  > $path/$c
            else
                # otherwise default to a tally
                current=$(cat $path/$c)
                echo $((current+1)) > $path/$c
            fi
            echo "1" > $flag
        done &
        if ((num_jobs==max_jobs)); then
            wait
            num_jobs=0
        fi
    done
    wait
    (($(cat $flag)==1)) && create_csv $csv_path $data_tmp
    rm $flag
}

