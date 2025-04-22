#!/bin/bash -eu
#
# Description: ovs bfd state changs
#

# NOTE: only run this for ovs-vswitchd logs
LOG_NAME_FILTER=ovs-vswitchd.log
LOG_MODULE='\|bfd(\S+)?\|'
Y_LABEL=ovs-bfd-state-change

main ()
{
    row_expr='^[0-9-]+T([0-9:]+)\.[0-9]+Z.+\|bfd(\S+)?\|\S+\|(\S+): BFD state change: (\S+)'
    process_log_tally $LOG $DATA_TMP $CSV_PATH "$row_expr" true $Y_LABEL
}
