process_log_deltas ()
{
    (($#==5)) || { echo "ERROR: insufficient args ($#) to process_log_deltas()"; exit 1; }
    local logfile=$1
    local data_tmp=$2
    local csv_path=$3
    local cols_expr="$4"
    local rows_expr="$5"
    local catcmd=cat
    local max_jobs=10
    local num_jobs=0
    local label=
    local current=
    local path=
    declare -A range_starts=()
    declare -A range_ends=()

    #echo "Searching $logfile (lines=$(wc -l $logfile| cut -d ' ' -f 1))"

    ensure_csv_path $csv_path
    file --mime-type $logfile| grep -q application/gzip && catcmd=zcat

    readarray -t starts<<<$(get_categories $catcmd $logfile "s/$cols_expr/\0/p")
    (( ${#starts[@]} )) && [[ -n ${starts[0]} ]] || return

    readarray -t ends<<<$(get_categories $catcmd $logfile "s/$rows_expr/\0/p")
    (( ${#ends[@]} )) && [[ -n ${ends[0]} ]] || return

    for line in "${starts[@]}"; do
        info=( $(echo "$line"| sed -rn "s/$cols_expr/\1 \2/p") )
        start=${info[0]}
        resource=${info[1]}
        [[ ${range_starts[$resource]:-null} = null ]] || echo "WARNING: resource $resource found more than once"
        range_starts[$resource]=$start
    done

    for line in "${ends[@]}"; do
        info=( $(echo "$line"| sed -rn "s/$rows_expr/\1 \3/p") )
        ends=${info[0]}
        resource=${info[1]}
        range_ends[$resource]=$ends
    done

    label=$(get_script_name)_deltas
    init_dataset $data_tmp "" $label
    for resource in ${!range_starts[@]}; do
        [[ -n ${range_ends[$resource]:-""} ]] || continue
        info=( $(python3 $SCRIPT_ROOT/../python/datecheck.py \
                    ${range_starts[$resource]} \
                    ${range_ends[$resource]}) )
        ((${#info[@]})) || continue
        t=${info[0]}
        path=${data_tmp}/${t//:/_}
        current=$(cat $path/$label)
        ((current<${info[1]})) || continue
        echo ${info[1]} > $path/$label
    done
    create_csv $csv_path $data_tmp
}
