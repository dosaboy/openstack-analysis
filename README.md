# OpenStack Analysis

Extract datapoints from logfiles and plot them as a graph.

## How to run

```bash
./run.sh --path <sosreport path> --plot
```

Then to display the graphs one host as a time:

```bash
./show_graphs
```

Or show a single page with graphs either grouped by host or grouped by agent/module:

```
firefox <resultsdir>/summary_by_agent.html
firefox <resultsdir>/summary_by_host.html
```


## How to plot a new datapoint

Datapoints are searched using *scripts* that are run in parallel as *jobs*.

These take very simple form. Here is an example script and explanation:

```bash
#
# Description: capture amount of time nova-compute takes to acquire a lock
#

# NOTE: only run this for nova-compute logs
LOG_NAME_FILTER=nova-compute.log
LOG_MODULE=oslo_concurrency.lockutils
Y_LABEL=max-lock-acquire-time

main ()
{
    col_expr="$EXPR_LOG_DATE $EXPR_LOG_CONTEXT Lock \\\"\S+\\\" acquired by \\\"(\S+)\\\" :: waited [1-9][0-9]*\.[0-9]+s .+"
    row_expr="$EXPR_LOG_DATE_GROUP_TIME $EXPR_LOG_CONTEXT Lock \\\"\S+\\\" acquired by \\\"\$INSERT\\\" :: waited ([1-9][0-9]*)\.[0-9]+s .+"
    process_log_tally_multicol $(filter_log $LOG $LOG_MODULE) $DATA_TMP $CSV_PATH "$col_expr" "$row_expr" 2 true
}
```

The above script sets the following required global variables:

* LOG_MODULE: (required) a log module name to filter correct log lines
* Y_LABEL: (required) the name given to the y-axis when the data is plotted as a graph
* LOG_NAME_FILTER: (optional) filter to ensure we only search required files

It also defines a main() function that is called when the job is run.
