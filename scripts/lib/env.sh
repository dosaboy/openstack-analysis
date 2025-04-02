#!/bin/bash -u

# GLOBALS
export OVERWRITE_CSV=false
export HOST_OVERRIDE=
export SOS_ROOT=
export PLOT_GRAPHS=false
export OUTPUT_PATH=results
export LOGROTATE=

usage ()
{
cat << EOF
NAME
    run - capture data and plot graphs

SYNOPSIS
    Capture data from log files and save in CSV format. This can then be
    plotted.

    --overwrite
        Overwrite existing CSV files. Defaults to false.
    --host
        Filter a specific host.
    --path
        Path to one or more unpacked sosreport.
    --plot
        Plot graphs from CSV data once complete.
    --logrotate
        By default we look at the current log i.e. ".log" but this can be set
        to ".7.gz".

EOF
}

while (($# > 0)); do
    case "$1" in
        --overwrite)
            OVERWRITE_CSV=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --host)
            HOST_OVERRIDE=$2
            shift
            ;;
        --path)
            SOS_ROOT=$2
            shift
            ;;
        --plot)
            PLOT_GRAPHS=true
            ;;
        --logrotate)
            LOGROTATE=$2
            shift
            ;;
        -*)
            echo "ERROR: invalid opt '$1'"
            exit 1
            ;;
    esac
    shift
done

