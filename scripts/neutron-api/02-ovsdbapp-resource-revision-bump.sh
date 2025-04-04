#!/bin/bash -eu
#
# Description: capture ovn resource revision bumps
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER neutron.db.ovn_revision_numbers_db

expr1="s/$EXPR_LOG_DATE $EXPR_LOG_CONTEXT Successfully bumped revision number for resource (\S+) \(type: \S+\) to [0-9]+/\1/p"
expr2="s/$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Successfully bumped revision number for resource \$INSERT \(type: \S+\) to [0-9]+/\1/p"
process_log_aggr $(filter_log $LOG $LOG_MODULE) $DATA_TMP $CSV_PATH "$expr1" "$expr2"

SCRIPT_FOOTER resource-revision-bumps
