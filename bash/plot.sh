#!/bin/bash -eu
SCRIPT_ROOT=$(dirname $(readlink --canonicalize $0))
HOST_OVERRIDE=${1:-""}

echo "Plotting graphs..."
if [[ -n $HOST_OVERRIDE ]]; then
    rm graphs/$HOST_OVERRIDE/*
    find results_data -name \*.csv| grep $HOST_OVERRIDE| \
        xargs -l python3 $SCRIPT_ROOT/../python/plot.py
else
    rm -rf graphs/*
    find results_data -name \*.csv| \
        xargs -l python3 $SCRIPT_ROOT/../python/plot.py
fi

