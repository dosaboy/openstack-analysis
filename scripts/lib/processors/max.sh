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
    #              name. Must match exactly three groups; date, time and column
    #              name.
    #   filter_log_module: Apply the default filter of LOG_MODULE to the
    #                      logfile prior to searching.
    #   squash_columns: by default we group results by column but can squash
    #                   them together by setting this to true.

    (($#>=6)) || { echo "ERROR: insufficient args ($#) to process_log_max()"; exit 1; }
    # Opts
    local logfile=$1
    local data_tmp=$2
    local csv_path=$3
    local cols_expr="$4"
    local rows_expr="$5"
    local filter_log_module=$6
    local squash_columns=${7:-false}
    # Vars
    local catcmd=cat
    local max_jobs=10
    local num_jobs=0
    local current=
    local path=
    local datetime=
    local colname=
    local split=()

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

    cols_expr="s,$cols_expr,\1,p"
    readarray -t cols<<<$(get_categories $catcmd $logfile "$cols_expr")
    (( ${#cols[@]} )) && [[ -n ${cols[0]} ]] || return 0

    rows_expr="s,$rows_expr,\1T\2 \3,p"
    flag=$(mktemp)
    echo "0" > $flag
    # Set INSERT var to column name
    for INSERT in ${cols[@]}; do
        colname=$INSERT
        if $squash_columns; then
            colname=all_projects
        fi
        ((num_jobs+=1))
        readarray -t rows<<<$($catcmd $logfile| sed -rn "$(eval echo \"$rows_expr\")")
        (( ${#rows[@]} )) && [[ -n ${rows[0]} ]] || continue
        for row in "${rows[@]}"; do
            declare -a split=( $row )
            # round to nearest 10 minutes
            datetime=${split[0]::-4}0
            path=${data_tmp}/${datetime//:/_}
            [[ -r $path/$colname ]] || init_dataset $data_tmp ${datetime%T*} $colname
            current=$(cat $path/$colname)
            # Store max
            if ((${split[1]} > ${current:-0})); then
                echo ${split[1]} > $path/$colname
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

