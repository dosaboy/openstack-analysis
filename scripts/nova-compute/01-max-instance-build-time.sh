#!/bin/bash -eu
#
# Description: capture max amount of time taken to build instances.
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER nova.compute.manager

expr1="s/$EXPR_LOG_DATE $EXPR_LOG_CONTEXT_GROUP_USER .+ Took [0-9.]+ seconds to build instance./\1/p"
expr2="s/$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT_INSERT_USER .+ Took ([0-9]+).[0-9]+ seconds to build instance./\1 \2/p"
process_log_max $LOG $DATA_TMP $CSV_PATH "$expr1" "$expr2" true

SCRIPT_FOOTER max-instance-build-time
