#!/bin/bash -eu
HOST=${1:-""}
BIN_ROOT=$(dirname $(readlink --canonicalize $0))
SCRIPT_ROOT=$BIN_ROOT/../scripts
. $SCRIPT_ROOT/lib/env.sh
GRAPHS_PATH=$OUTPUT_PATH/graphs

if ! [[ -d $GRAPHS_PATH ]]; then
    echo "INFO: no graphs found to show ($GRAPHS_PATH)"
    exit 1
fi

for host in $(ls $GRAPHS_PATH); do
    if [[ -n $HOST ]]; then
        [[ $HOST == $host ]] || continue
    fi
    find $GRAPHS_PATH/$host -name \*.png| xargs firefox
done
