#!/bin/bash -eu
BIN_ROOT=$(dirname $(readlink --canonicalize $0))
SCRIPT_ROOT=$BIN_ROOT/../scripts
. $SCRIPT_ROOT/lib/env.sh
DATA_PATH=$OUTPUT_PATH/data
GRAPHS_PATH=$OUTPUT_PATH/graphs
PYTHON_SCRIPTS=$SCRIPT_ROOT/../python

if ! [[ -d $DATA_PATH ]]; then
    echo "INFO: no data found to plot"
    exit 1
fi

echo "Plotting graphs..."
ARGS=( --data-path $DATA_PATH --output-path $OUTPUT_PATH )
if $OVERWRITE_CSV; then
    ARGS+=( --overwrite )
fi
if (( ${#HOST_OVERRIDE[@]} )); then
    for host in ${HOST_OVERRIDE[@]}; do
        ARGS+=( --host $host )
        $OVERWRITE_CSV && rm -f $GRAPHS_PATH/$host/*
    done
else
    $OVERWRITE_CSV && rm -rf $GRAPHS_PATH/*
fi
python3 $PYTHON_SCRIPTS/plot.py ${ARGS[@]}

