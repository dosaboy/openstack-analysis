process_log_deltas_multicol ()
{
    # Description:
    #   Identify start and end times for an event using a search
    #   expression for each then calculate the time delta and
    #   save the maximum occurence per 10 minute window. Values are
    #   grouped by resource name (with uuid suffix removed).
    #
    #   The resulting csv data will have one y-axis column
    #   and a row for every ten minutes of time.
    #
    # Params:
    #   logfile: path to logfile
    #   data_tmp: path to temporary directory used to store data
    #   csv_path: path to output CSV file
    #   seq_start_expr: regular expression (sed) used to identify the start of
    #                   the delta sequence. Must identify three result groups;
    #                   first is date, second is time and third is a unique id
    #                   used to group results.
    #   seq_end_expr: regular expression (sed) used used to identify the end of
    #                 the delta sequence. Must identify three result groups;
    #                 first is date, second is time and third is a unique id
    #                 used to group results.
    #   filter_log_module: Apply the default filter of LOG_MODULE to the
    #                      logfile prior to searching.

    (($#==6)) || { echo "ERROR: insufficient args ($#) to process_log_deltas_multicol()"; exit 1; }
    process_log_deltas "$@" true
}
