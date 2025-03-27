#!/bin/bash -eu
#
# Description: looks at backlog of concurrent build requests nova-compute
#              processes while building a new vm.
#
. $SCRIPT_ROOT/lib.sh

process_log ()
{
    local LOG=$1
    local DATA_TMP=$2
    local CSV_PATH=$3
    local CATCMD
    local MAX_JOBS=10
    local NUM_JOBS=0
    local current=
    local path=
    local vm=
    local start=
    local end=

    ensure_csv_path $CSV_PATH
    file --mime-type $LOG| grep -q application/gzip && CATCMD=zcat || CATCMD=cat

    e1="s/$EXPR_LOG_DATE $EXPR_LOG_CONTEXT $EXPR_LOG_INSTANCE_UUID Took [0-9.]+ seconds to build instance./\0/p"
    readarray -t ends<<<$(get_categories $CATCMD $LOG "$e1")
    (( ${#ends[@]} )) && [[ -n ${ends[0]} ]] || return

    declare -A BUILD_STARTS=()
    declare -A BUILD_ENDS=()
    declare -A BUILD_BACKLOGS=()
    declare -A BUILD_ENDS_TIMES=()

    grep -q " _do_build_and_run_instance" $LOG || return

    for line in "${ends[@]}"; do
        buildtime=$(echo "$line"| sed -rn 's/.+ Took ([0-9]+).[0-9]+ seconds .+/\1/p')
        (($buildtime>30)) || continue
        logtime=$(echo "$line"| sed -rn "s/$EXPR_LOG_DATE_GROUP_TIME .+/\1/p")
        # round to nearest 10 minutes
        logtime=${logtime[0]::4}0
        vm=$(echo "$line"| sed -rn "s/.+ $EXPR_LOG_INSTANCE_UUID_GROUP_UUID .+/\1/p")
        BUILD_ENDS_TIMES[$vm]=$logtime
        end=$(grep -nF "$line" $LOG| cut -d ':' -f 1)
        BUILD_ENDS[$vm]=$end
    done

    for vm in ${!BUILD_ENDS[@]}; do
        start=$(egrep -n " \[instance: $vm\] Starting instance\.\.\. _do_build_and_run_instance " $LOG| cut -d ':' -f 1)
        BUILD_STARTS[$vm]=$start
    done

    for vm in ${!BUILD_STARTS[@]}; do
        start=${BUILD_STARTS[$vm]}
        end=${BUILD_ENDS[$vm]}
        backlog=$(tail -n +$start $LOG| head -n $(($end - $start))| sed -rn 's/.+ (\[.+\] (Starting instance|Claim successful|VM Started \(Lifecycle Event\).+)|Deleted allocations.+).+/\1/p'| wc -l)
        BUILD_BACKLOGS[$vm]=$backlog
    done

    key=vm-builds-gt-60-aggregate-backlog
    init_dataset $DATA_TMP "" $key

    for vm in ${!BUILD_BACKLOGS[@]}; do
        # round to nearest 10 minutes
        t=${BUILD_ENDS_TIMES[$vm]::4}0
        path=${DATA_TMP}/${t//:/_}
        current=$(cat $path/$key)
        backlog=${BUILD_BACKLOGS[$vm]}
        echo $((current+backlog)) > $path/$key
    done
    create_csv $CSV_PATH $DATA_TMP
}

SCRIPT_HEADER nova.compute.manager

process_log $(filter_log $LOG $LOG_MODULE) $DATA_TMP $CSV_PATH

SCRIPT_FOOTER instance-build-backlog-size
