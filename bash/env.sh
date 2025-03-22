#!/bin/bash -u

# GLOBALS
export OVERWRITE_CSV=false
export HOST_OVERRIDE=
export SOS_ROOT=
export PLOT_GRAPHS=false
export OUTPUT_PATH=results
export LOGROTATE=

while (($# > 0)); do
    case "$1" in
        --overwrite)
            OVERWRITE_CSV=true
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

