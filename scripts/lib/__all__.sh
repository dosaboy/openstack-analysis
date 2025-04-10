__ROOT__=$(dirname $0)
echo "INFO: preparing $(basename $__ROOT__) jobs for $LOG"
for script in $(ls $__ROOT__/*);do
    [[ $(basename $script) = $(basename $0) ]] && continue
    sname=$(basename $script)
    [[ -z $SCRIPT_OVERRIDE ]] || [[ $SCRIPT_OVERRIDE = ${sname%*.sh} ]] || continue
    jobpath=$JOBS_DEFS_DIR/$(uuidgen)
    mkdir $jobpath
    declare -x > $jobpath/run.sh
    echo $script >> $jobpath/run.sh
    chmod +x $jobpath/run.sh
done
wait
