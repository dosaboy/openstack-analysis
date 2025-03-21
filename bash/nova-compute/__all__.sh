__ROOT__=$(dirname $0)
echo "INFO: running all nova-compute scripts (LOG=$LOG)"
#$__ROOT__/01-do-build-and-run-instance.sh &
#$__ROOT__/01-max-instance-build-time.sh &
#$__ROOT__/02-build-instance-abort.sh &
#$__ROOT__/03-terminating-instance.sh &
#$__ROOT__/04-txn-queue-full.sh &
#$__ROOT__/05-rabbitmq-heartbeats-missed.sh &
#$__ROOT__/06-ovsdbapp-timeout.sh &
#$__ROOT__/07-max-lock-held-time.sh &
#$__ROOT__/08-service-start.sh &
#$__ROOT__/09-oslo-messaging-timeout.sh &
#$__ROOT__/10-build-backlog.sh &
#$__ROOT__/11-ovsdbapp-txn.sh &
$__ROOT__/12-update-network-info.sh &
#$__ROOT__/13-network-allocate-for-instance.sh &
#$__ROOT__/14-os-vif-plug.sh &
#$__ROOT__/15-resource-tracker-vcpus.sh &
#$__ROOT__/15-resource-tracker-memory.sh &
#$__ROOT__/15-resource-tracker-disk.sh &
wait
