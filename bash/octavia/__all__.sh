__ROOT__=$(dirname $0)
echo "INFO: running all octavia scripts (LOG=$LOG)"
$__ROOT__/01-lb-creates.sh &
$__ROOT__/02-lb-create-time.sh &
wait
