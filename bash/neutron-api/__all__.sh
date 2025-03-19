__ROOT__=$(dirname $0)
echo "INFO: running all neutron-api scripts (LOG=$LOG)"
# This one can take a very long time to run if the log is large so dont run by default
#$__ROOT__/01-http-return-codes.sh &
$__ROOT__/02-ovsdbapp-leadership.sh &
wait
