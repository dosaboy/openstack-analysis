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
if [[ -n $HOST_OVERRIDE ]]; then
    rm -f $GRAPHS_PATH/$HOST_OVERRIDE/*
    find $DATA_PATH -name \*.csv| grep $HOST_OVERRIDE| \
        xargs -l python3 $PYTHON_SCRIPTS/plot.py
else
    rm -rf $GRAPHS_PATH/*
    find $DATA_PATH -name \*.csv| \
        xargs -l python3 $PYTHON_SCRIPTS/plot.py
fi

