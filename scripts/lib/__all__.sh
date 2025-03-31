__ROOT__=$(dirname $0)
echo "INFO: running all $(basename $__ROOT__) scripts (LOG=$LOG)"
for script in $(ls $__ROOT__/*);do
    [[ $(basename $script) = $(basename $0) ]] && continue
    $script &
done
wait
