#!/bin/bash -eu
#
# Description: 
#
. $SCRIPT_ROOT/lib/helpers.sh

# NOTE: only run this for apache logs
[[ $LOG =~ apache2 ]] || exit 0

SCRIPT_HEADER ' - '

y_label=http-return-codes

col_expr='.+ HTTP/1.1" ([0-9]{3}) .+'
row_expr='.+\[\S+:([0-9]+:[0-9]+:[0-9]+) \+[0-9]+\] .+ HTTP/1.1\" $INSERT .+'
process_log_aggr2 $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 1 false

SCRIPT_FOOTER $y_label
