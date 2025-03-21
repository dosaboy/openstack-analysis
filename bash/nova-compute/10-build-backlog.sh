#!/bin/bash -eu
#
# Description: looks at backlog of concurrent build requests nova-compute
#              processes while building a new vm.
#
. $SCRIPT_ROOT/lib.sh
RESULTS_DIR=results_data/$(basename $0| sed -r 's/[0-9]+-(.+)\.sh/\1/'| tr '-' '_')
mkdir -p $RESULTS_DIR

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

    ensure_csv_path
    file --mime-type $LOG| grep -q application/gzip && CATCMD=zcat || CATCMD=cat

    e1='s/[0-9-]+ ([0-9:]+:[0-9])[0-9]:[0-9]+.[0-9]+ [0-9]+ \w+ nova.compute.manager \[req-[0-9a-z-]+ ([0-9a-z-]+) ([0-9a-z-]+) .+\] \[instance: ([0-9a-z-]+)\] Took [0-9.]+ seconds to build instance./\0/p'
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
        logtime=$(echo "$line"| sed -rn 's/[0-9-]+ ([0-9:]+:[0-9])[0-9]:[0-9]+.[0-9]+ .+/\10/p')
        vm=$(echo "$line"| sed -rn 's/.+ \[instance: ([0-9a-z-]+)\] .+/\1/p')
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
        t=${BUILD_ENDS_TIMES[$vm]}
        path=${DATA_TMP}/${t//:/_}
        current=$(cat $path/$key)
        backlog=${BUILD_BACKLOGS[$vm]}
        echo $((current+backlog)) > $path/$key
    done
    create_csv $CSV_PATH $DATA_TMP
}

data_tmp=`mktemp -d -p $RESULTS_DIR`
csv_path=$RESULTS_DIR/${HOSTNAME}_$(basename $RESULTS_DIR).csv
module=nova.compute.manager

FILTERED=$(mktemp -p $data_tmp)
grep $module $LOG > $FILTERED
process_log $FILTERED $data_tmp $csv_path

write_meta $RESULTS_DIR time instance-build-backlog-size
cleanup $data_tmp $csv_path

