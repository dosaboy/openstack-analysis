#!/usr/bin/python3
from datetime import datetime
import sys

HMS_FMT = '%H:%M:%S'
ISO8601_FMT = f'%Y-%m-%dT{HMS_FMT}'


def strptimes(from_date, to_date):
    try:
        _from = datetime.strptime(from_date, HMS_FMT)
        _to = datetime.strptime(to_date, HMS_FMT)
    except ValueError:
        _from = datetime.strptime(from_date, ISO8601_FMT)
        _to = datetime.strptime(to_date, ISO8601_FMT)

    return _from, _to


def main(from_date, to_date):
    """
    Ensure from_date is earlier than to_date.

    Exit with 0 if pass or 1 if fail.

    @param from_date: string from date
    @param to_date: string to date
    """
    _from, _to = strptimes(from_date, to_date)
    if _from > _to:
        sys.exit(1)

    sys.exit(0)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
