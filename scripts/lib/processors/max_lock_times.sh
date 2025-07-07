# Description: capture amount of time nova-compute locks are held for.

is_uuid ()
{
    if $(echo "$1"| egrep -q "([0-9a-z]){32}"); then
        return 0
    elif $(echo "$1"| egrep -q "([0-9a-z-]){36}"); then
        return 0
    else
        return 1
    fi
}

dedup ()
{
    local tag=$1
    local time_limit_min=$2
    shift 2
    local cols=( "$@" )
    local name=
    local time=

    # Aggregate all resource locks into a single entry so that the others are easier to distinguish
    declare -A _filtered[$tag]=0
    for c in "${cols[@]}"; do
        declare -a _c=( $c )
        name=${_c[0]}
        DEDUP_DARRAY_STORE[$name]=0
        time=${_c[1]}
        (($time>=$time_limit_min)) || continue
        if ! is_uuid $name; then
            _filtered[$name]=0
        fi
    done
}

process_log_max_lock_times ()
{
    # Description: 
    #   Identify one more resources/columns then for every 10 minute window,
    #   tally the occurence of each resource OR optionally save their value.
    #
    #   The default tally behaviour is used if the search results contain only
    #   time and resource/column name and if there is a third group that is
    #   used as the value to save.
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
    #   filter_log_module: Apply the default filter of LOG_MODULE to the
    #                      logfile prior to searching.

    (($#==6)) || { echo "ERROR: insufficient args ($#) to process_log_custom()"; exit 1; }
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
    local datetime=
    local time_limit_min=30
    local resource_tag=NOVA_RESOURCES
    declare -A deduped=()

    log_debug "searching $logfile (lines=$(wc -l $logfile| cut -d ' ' -f 1))"
    ensure_csv_path $csv_path || return

    if $filter_log_module; then
        log_debug "filtering log using '$LOG_MODULE' (script=$__SCRIPT_NAME__)"
        logfile=$(filter_log $logfile $LOG_MODULE)
    fi

    file --mime-type $logfile| grep -q application/gzip && catcmd=zcat

    readarray -t cols<<<$(get_categories $catcmd $logfile "s,$cols_expr,\1 \2,p")
    (( ${#cols[@]} )) && [[ -n ${cols[0]} ]] || return 0

    declare -n DEDUP_DARRAY_STORE="deduped"
    dedup $resource_tag $time_limit_min "${cols[@]}"

    rows_expr="s,$rows_expr,\1T\2,p"
    flag=$(mktemp)
    echo "0" > $flag
    # Set INSERT var to column name
    for INSERT in "${cols[@]}"; do
        declare -a split_col=( $INSERT )
        name=${split_col[0]}
        time=${split_col[1]}

        (($time>=$time_limit_min)) || continue

        ((${deduped[$name]}==0)) || continue
        deduped[$name]=1

        ((num_jobs+=1))
        readarray -t rows<<<$($catcmd $logfile| sed -rn "$(eval echo \"$rows_expr\")")
        (( ${#rows[@]} )) && [[ -n ${rows[0]} ]] || continue
        for datetime in "${rows[@]}"; do
            # round to nearest 10 minutes
            datetime=${datetime[0]::-4}0
            path=${data_tmp}/${datetime//:/_}
            if is_uuid $name; then
                name=$resource_tag
            fi
            [[ -r $path/$name ]] || init_dataset $data_tmp ${datetime%T*} $name
            current=$(cat $path/$name)
            # Store max
            ((time > current)) || continue
            echo $time > $path/$name
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

