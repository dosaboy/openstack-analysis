process_log_aggr2 ()
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
    #              Must identify one result group that matches a column
    #              name.
    #   rows_expr: regular expression (sed) used to identify rows.
    #              This expression will typically be the same as cols_expr
    #              but with an $INSERT variable in place of the column
    #              name. Must match at least two groups.
    #   num_row_groups: number of groups in row results. this must match the
    #                   expression provided.
    #   filter_log_module: Apply the default filter of LOG_MODULE to the
    #                      logfile prior to searching.

    (($#==7)) || { echo "ERROR: insufficient args ($#) to process_log_aggr2()"; exit 1; }
    local logfile=$1
    local data_tmp=$2
    local csv_path=$3
    local cols_expr="$4"
    local rows_expr="$5"
    local num_row_groups=$6
    local filter_log_module=$7
    local catcmd=cat
    local rownum=0
    local _time=
    local current=
    local path=
    declare -A cache=()

    #echo "Searching $logfile (lines=$(wc -l $logfile| cut -d ' ' -f 1))"

    ensure_csv_path $csv_path

    if $filter_log_module; then
        echo "INFO: filtering log using '$LOG_MODULE' (script=$(get_script_name))"
        logfile=$(filter_log $logfile $LOG_MODULE)
    fi

    file --mime-type $logfile| grep -q application/gzip && catcmd=zcat

    declare -a cols=( $(get_categories $catcmd $logfile "s,$cols_expr,\1,p") )
    (( ${#cols[@]} )) && [[ -n ${cols[0]} ]] || return 0

    init_dataset $data_tmp "" ${cols[@]}

    INSERT="($(echo ${cols[@]}| tr ' ' '|'))"
    rows_expr="s,$rows_expr,"

    # add one for the insert group
    num_row_groups=$((num_row_groups + 1))
    for ((i=1; i<num_row_groups+1; i+=1)); do
        rows_expr+="\\$i "
    done
    rows_expr="${rows_expr% },p"

    readarray -t rows<<<$($catcmd $logfile| sed -rn "$(eval echo \"$rows_expr\")")
    (( ${#rows[@]} )) && [[ -n ${rows[0]} ]] || return

    for row in "${rows[@]}"; do
        rownum=$((rownum+=1))
        declare -a split=( $row )
        # round time to nearest 10 minutes
        t=${split[0]::4}0
        col=${split[1]}
        ## CACHE
        if [[ $_time = $t ]]; then
            if ((${#split[@]} > 2)); then
                # if more than one result group exists use the second group as the value
                cache[$col]=${split[2]}
            else
                cache[$col]=$((${cache[$col]:-0}+1))
            fi
            (($rownum<${#rows[@]})) && continue
        elif [[ -z $_time ]] && (($rownum==${#rows[@]})); then
            # support only one matching row
            _time=$t
            cache=( [$col]=1 )
        fi
        ## FLUSH
        if [[ -n $_time ]]; then
            path=${data_tmp}/${_time//:/_}
            for _col in ${!cache[@]}; do
                if ((${#split[@]} > 2)); then
                    echo ${cache[$_col]} > $path/$_col
                else
                    current=$(cat $path/$_col)
                    echo $((${cache[$_col]} + current)) > $path/$_col
                fi
            done
        fi
        ## SET
        _time=$t
        cache=( [$col]=1 )
    done
    (($rownum)) && create_csv $csv_path $data_tmp
}

