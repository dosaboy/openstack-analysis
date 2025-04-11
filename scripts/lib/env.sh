#!/bin/bash -u

# GLOBALS
export OVERWRITE_CSV=false
export HOST_OVERRIDE=
export SOS_ROOT=
export PLOT_GRAPHS=false
export OUTPUT_PATH=results
export AGENT_SCRIPTS=
export SCRIPT_OVERRIDE=
export LOGROTATE=
export MAX_CONCURRENT_JOBS=8

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
    --agent
        Run scripts for a specific agent.
    --script
        Run a specific script
    -j|--jobs
        Maximum number of jobs to run in parallel. Default is $MAX_CONCURRENT_JOBS.
    --path
        Path to one or more unpacked sosreport.
    --output
        Output path for data and graphs. Default is $OUTPUT_PATH
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
        --agent)
            AGENT_SCRIPTS=$2
            shift
            ;;
        -j|--jobs)
            MAX_CONCURRENT_JOBS=$2
            shift
            ;;
        --host)
            HOST_OVERRIDE=$2
            shift
            ;;
        --path)
            SOS_ROOT=$2
            shift
            ;;
        --output)
            OUTPUT_PATH=$2
            shift
            ;;
        --plot)
            PLOT_GRAPHS=true
            ;;
        --script)
            SCRIPT_OVERRIDE=$2
            shift
            ;;
        --logrotate)
            LOGROTATE=".log$2"
            shift
            ;;
        -*)
            echo "ERROR: invalid opt '$1'"
            exit 1
            ;;
    esac
    shift
done

export LOCKFILE=$OUTPUT_PATH/lock

