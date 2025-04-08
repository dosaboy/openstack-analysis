#!/bin/bash -eu
#
# Description: capture ovn resource revision bumps
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER neutron.db.ovn_revision_numbers_db

expr1="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT Successfully bumped revision number for resource \S+ \(type: (\S+)\) to [0-9]+"
expr2="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Successfully bumped revision number for resource \S+ \(type: \$INSERT\) to [0-9]+"
process_log_aggr2 $LOG $DATA_TMP $CSV_PATH "$expr1" "$expr2" 1 true

SCRIPT_FOOTER resource-revision-bumps
