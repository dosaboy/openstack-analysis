#!/bin/bash -eu
#
# Description: plot instances of LSP not found
#

# NOTE: only run this for neutron-server logs
LOG_NAME_FILTER=neutron-server.log
LOG_MODULE=neutron.plugins.ml2.managers
Y_LABEL=logical-switch-port-not-exists
PLOT_TYPE=stackplot

main ()
{
    row_expr="$EXPR_LOG_DATE_GROUP_TIME [0-9]+ \w+ $LOG_MODULE RuntimeError: Logical Switch Port [0-9a-z-]+ does not exist"
    process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true $Y_LABEL
}
