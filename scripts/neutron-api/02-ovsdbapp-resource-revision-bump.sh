#!/bin/bash -eu
#
# Description: capture ovn resource revision bumps
#
. $SCRIPT_ROOT/lib/helpers.sh

SCRIPT_HEADER neutron.db.ovn_revision_numbers_db

col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT Successfully bumped revision number for resource \S+ \(type: (\S+)\) to [0-9]+"
row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Successfully bumped revision number for resource \S+ \(type: \$INSERT\) to [0-9]+"
process_log_aggr2 $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 1 true

SCRIPT_FOOTER resource-revision-bumps
