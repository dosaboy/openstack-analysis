__ROOT__=$(dirname $0)
echo "INFO: running all ovn scripts (LOG=$LOG)"
#$__ROOT__/01-leadership-transitions.sh &
$__ROOT__/02-inactivity-probe-timeout.sh &
wait
