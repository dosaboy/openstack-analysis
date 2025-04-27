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


process_log ()
{
    # OVERRIDE DEFAULT PROCESSOR

    # Opts
    local logfile=$1
    local data_tmp=$2
    local csv_path=$3
    local cols_expr="$4"
    local rows_expr="$5"
    # Vars
    local catcmd=cat
    local max_jobs=10
    local num_jobs=0
    local current=
    local path=
    local datetime=

    log_debug "searching $logfile (lines=$(wc -l $logfile| cut -d ' ' -f 1))"
    ensure_csv_path $csv_path || return

    file --mime-type $logfile| grep -q application/gzip && catcmd=zcat

    cols_expr="s,$cols_expr,\1 \2,p"
    readarray -t cols<<<$(get_categories $catcmd $logfile "$cols_expr")
    (( ${#cols[@]} )) && [[ -n ${cols[0]} ]] || return 0

    TIME_LIMIT_MIN=30
    RESOURCE_TAG=NOVA_RESOURCES

    declare -A deduped=()
    # Aggregate all resource locks into a single entry so that the others are easier to distinguish
    declare -A _filtered[$RESOURCE_TAG]=0
    for c in "${cols[@]}"; do
        declare -a _c=( $c )
        name=${_c[0]}
        deduped[$name]=0
        time=${_c[1]}
        (($time>=$TIME_LIMIT_MIN)) || continue
        if ! is_uuid $name; then
            _filtered[$name]=0
        fi
    done

    rows_expr="s,$rows_expr,\1T\2,p"
    flag=$(mktemp)
    echo "0" > $flag
    for c in "${cols[@]}"; do
        declare -a _c=( $c )
        name=${_c[0]}
        time=${_c[1]}
        (($time>=$TIME_LIMIT_MIN)) || continue

        ((${deduped[$name]}==0)) || continue
        deduped[$name]=1

        ((num_jobs+=1))
        for t in $($catcmd $logfile| sed -rn "$(eval echo \"$rows_expr\")"); do
            # round to nearest 10 minutes
            datetime=${t[0]::-4}0
            path=${data_tmp}/${datetime//:/_}
            if is_uuid $name; then
                name=$RESOURCE_TAG
            fi
            [[ -r $path/$name ]] || init_dataset $data_tmp ${datetime%T*} $name
            current=$(cat $path/$name)
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

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=oslo_concurrency.lockutils
Y_LABEL=max-lock-held-time
PLOT_TYPE=bar_stacked

main ()
{
    col_expr="$EXPR_LOG_DATE [0-9]+ \w+ $LOG_MODULE .+ Lock \\\"([a-z0-9_-]+)\\\" .+ :: held ([0-9]+).[0-9]+s.+"
    row_expr="$EXPR_LOG_DATE_GROUP_DATE_AND_TIME [0-9]+ \w+ $LOG_MODULE .+ Lock \\\"\$name\\\" .+ :: held [0-9]+.[0-9]+s.+"
    process_log $(filter_log $LOG $LOG_MODULE) $DATA_TMP $CSV_PATH "$col_expr" "$row_expr"
}
