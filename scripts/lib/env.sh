#!/bin/bash -u

# GLOBALS
export DEBUG_MODE=false
export OVERWRITE_CSV=false
export HOST_OVERRIDE=()
export SOS_ROOT=
export PLOT_GRAPHS=false
export OUTPUT_PATH=analysis_results
export AGENT_SCRIPTS=
export SCRIPT_OVERRIDE=
export LOGROTATE=
export MAX_CONCURRENT_JOBS=8
export GRAPH_DISPLAY_TYPE=host
export USER_FILTER=
# This can be used if we call scripts that accept the same opts to avoid having
# to repeat them explicity.
CLI_OPTS_CACHE=( "$@" )

usage ()
{
cat << EOF
NAME
    run - capture data and plot graphs

SYNOPSIS
    Capture data from log files and save in CSV format. This can then be
    plotted.

    --debug
        Enable debug logs.
    --filter
        Provide a filter to scipts. This must be grep regex compatiple.
    --overwrite
        Overwrite existing CSV files. Defaults to false.
    --host
        Filter a specific host. Can be specified multiple times.
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
        Integer logrotate depth. By default we look at the current log i.e. ".log"
        but e.g. if you want logs from 7 days ago (".log.7" or ".log.7.gz") set to 7.
    --group-by host|agent|tab
        By default graphs are displayed grouped by host on a single page. By
        setting this to agent or host you can view them on a single page either
        grouped by host or agent. If set to 'tab', graphs will be displayed as
        one graph per tab grouped by host.
EOF
}

while (($# > 0)); do
    case "$1" in
        --debug)
            DEBUG_MODE=true
            ;;
        --filter)
            USER_FILTER="$2"
            ;;
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
        --group-by)
            [[ $2 = agent ]] || [[ $2 = host ]] || [[ $2 = tab ]] || { echo "ERROR: invalid grouping type '$2'"; exit 1; }
            GRAPH_DISPLAY_TYPE=$2
            ;;
        -j|--jobs)
            MAX_CONCURRENT_JOBS=$2
            shift
            ;;
        --host)
            HOST_OVERRIDE+=( $2 )
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
            if [[ -n $2 ]] && (($2>0)); then
                LOGROTATE=".$2"
            fi
            shift
            ;;
        -*)
            echo "ERROR: invalid opt '$1'"
            exit 1
            ;;
    esac
    shift
done

if [[ -n $LOGROTATE ]]; then
    export OUTPUT_PATH=${OUTPUT_PATH}/${LOGROTATE#*.}
else
    export OUTPUT_PATH=${OUTPUT_PATH}/current
fi

export LOCKFILE=$OUTPUT_PATH/lock

