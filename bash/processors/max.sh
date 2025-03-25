process_log_max ()
{
    (($#==5)) || { echo "ERROR: insufficient args ($#) to process_log_max()"; exit 1; }
    local logfile=$1
    local data_tmp=$2
    local csv_path=$3
    local cols_expr="$4"
    local rows_expr="$5"
    local catcmd=cat
    local max_jobs=10
    local num_jobs=0
    local current=
    local path=

    #echo "Searching $logfile (lines=$(wc -l $logfile| cut -d ' ' -f 1))"

    ensure_csv_path $csv_path
    file --mime-type $logfile| grep -q application/gzip && catcmd=zcat

    declare -a cols=( $(get_categories $catcmd $logfile "$cols_expr") )
    (( ${#cols[@]} )) && [[ -n ${cols[0]} ]] || return

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

