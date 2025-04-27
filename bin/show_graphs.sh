#!/bin/bash -eu
BIN_ROOT=$(dirname $(readlink --canonicalize $0))
SCRIPT_ROOT=$BIN_ROOT/../scripts
. $SCRIPT_ROOT/lib/env.sh
GRAPHS_PATH=$OUTPUT_PATH/graphs

if ! [[ -d $GRAPHS_PATH ]]; then
    echo "INFO: path '$GRAPHS_PATH' not found. Use --output to provide another"
    exit 1
fi

graphs=()
for host in $(ls $GRAPHS_PATH); do
    if (( ${#HOST_OVERRIDE[@]} )); then
        echo ${HOST_OVERRIDE[@]}| egrep -q "( |^)$host( |\$)" || continue
        graphs+=( $(find $GRAPHS_PATH/$host -name \*.png) )
    else
        find $GRAPHS_PATH/$host -name \*.png| xargs firefox
    fi
done
((${#graphs[@]})) && firefox ${graphs[@]}
