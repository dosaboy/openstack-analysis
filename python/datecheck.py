#!/usr/bin/python3
import sys
from datetime import datetime, timedelta

HMS_FMT = '%H:%M:%S'
ISO8601_FMT = f'%Y-%m-%dT{HMS_FMT}'


def main(from_date, to_date):
    """
    Calculate difference between two dates and if it is non-zero return it as
    a string of the form "<date> <secs>" where date is the to date rounded to
    the nearest 10 minutes and secs is the difference between the two in
    seconds.

    The return is printed to standard output.

    @param from_date:
    @param to_date:
    """
    try:
        _from = datetime.strptime(from_date, HMS_FMT)
        _to = datetime.strptime(to_date, HMS_FMT)
    except ValueError:
        _from = datetime.strptime(from_date, ISO8601_FMT)
        _to = datetime.strptime(to_date, ISO8601_FMT)

    delta = _to - _from
    if delta > timedelta():
        print(f"{to_date[:-4]}0 {int(delta.total_seconds())}")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
