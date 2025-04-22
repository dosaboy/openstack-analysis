process_log_max ()
{
    # Description: 
    #   Identify one more resources/columns then for each get
    #   values within a 10 minute window and save the maximum
    #   value in that window.
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
    #              name. Must match exactly two groups; datetime and colname.
    #   filter_log_module: Apply the default filter of LOG_MODULE to the
    #                      logfile prior to searching.

    (($#==6)) || { echo "ERROR: insufficient args ($#) to process_log_max()"; exit 1; }
    # Opts
    local logfile=$1
    local data_tmp=$2
    local csv_path=$3
    local cols_expr="$4"
    local rows_expr="$5"
    local filter_log_module=$6
    # Vars
    local catcmd=cat
    local max_jobs=10
    local num_jobs=0
    local current=
    local path=

    #echo "Searching $logfile (lines=$(wc -l $logfile| cut -d ' ' -f 1))"

    ensure_csv_path $csv_path

    if $filter_log_module; then
        echo "INFO: filtering log using '$LOG_MODULE' (script=$__SCRIPT_NAME__)"
        logfile=$(filter_log $logfile $LOG_MODULE)
    fi

    file --mime-type $logfile| grep -q application/gzip && catcmd=zcat

    cols_expr="s,$cols_expr,\1,p"
    readarray -t cols<<<$(get_categories $catcmd $logfile "$cols_expr")
    (( ${#cols[@]} )) && [[ -n ${cols[0]} ]] || return 0

    rows_expr="s,$rows_expr,\1 \2,p"
    init_dataset $data_tmp "" ${cols[@]}
    flag=$(mktemp)
    echo "0" > $flag
    for c in ${cols[@]}; do
        ((num_jobs+=1))
        # Set INSERT var to column name
        INSERT=$c
        readarray -t rows<<<$($catcmd $logfile| sed -rn "$(eval echo \"$rows_expr\")")
        (( ${#rows[@]} )) && [[ -n ${rows[0]} ]] || continue
        for row in "${rows[@]}"; do
            declare -a split=( $row )
            # round to nearest 10 minutes
            t=${split[0]::4}0
            path=${data_tmp}/${t//:/_}
            current=$(cat $path/$c)
            # Store max
            if ((${split[1]} > $current)); then
                echo ${split[1]} > $path/$c
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

