process_log_simple ()
{
    (($#>4)) || { echo "ERROR: insufficient args to process_log_simple()"; exit 1; }
    local logfile=$1
    local data_tmp=$2
    local csv_path=$3
    local rows_expr="$4"
    shift 4
    local cols=( $@ )
    local catcmd=cat
    local path=

    #echo "Searching $logfile (lines=$(wc -l $logfile| cut -d ' ' -f 1))"

    ensure_csv_path $csv_path
    file --mime-type $logfile| grep -q application/gzip && catcmd=zcat

    readarray -t rows<<<$(get_categories $catcmd $logfile "$rows_expr")
    (( ${#rows[@]} )) && [[ -n ${rows[0]} ]] || return

    init_dataset $data_tmp "" ${cols[@]}
    for entry in "${rows[@]}"; do
        declare -a info=( $entry )
        t=${info[0]}
        path=${data_tmp}/${t//:/_}
        for ((i=1; i<=${#cols[@]}; i+=1)); do
            echo "${info[$i]}" > $path/${cols[$((i-1))]}
        done
    done
    create_csv $csv_path $data_tmp
}

