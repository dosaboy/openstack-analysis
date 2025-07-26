# Description: plot apache http return codes.

skip "does not currently work because of apache date format - needs to not contain whitespace"

# NOTE: only run this for apache logs
LOG_NAME_FILTER=apache2
LOG_MODULE=' - '
Y_LABEL=http-return-codes
PLOT_TYPE=bar_stacked
PLOT_TITLE="Apache Http Return Codes"

main ()
{
    col_expr='.+ HTTP/1.1" ([0-9]{3}) .+'
    row_expr='.+\[(\S+):([0-9]+:[0-9]+:[0-9]+) \+[0-9]+\] .+ HTTP/1.1\" $INSERT .+'
    process_log_tally_multicol $LOG $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 0 false
}
