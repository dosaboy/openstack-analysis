__ROOT__=$(dirname $0)
echo "INFO: running all ovn scripts (LOG=$LOG)"
for script in $(ls $__ROOT__/*);do
    [[ $(basename $script) = $(basename $0) ]] && continue
    $script &
done
wait
