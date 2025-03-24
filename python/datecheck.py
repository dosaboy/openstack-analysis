#!/usr/bin/python3
import sys
from datetime import datetime, timedelta


if __name__ == "__main__":
    FMT = '%H:%M:%S'
    try:
        _from = datetime.strptime(sys.argv[1], FMT)
        _to = datetime.strptime(sys.argv[2], FMT)
    except ValueError:
        FMT = '%Y-%m-%dT%H:%M:%S'
        _from = datetime.strptime(sys.argv[1], FMT)
        _to = datetime.strptime(sys.argv[2], FMT)

    delta = _to - _from
    if delta > timedelta():
        print(f"{sys.argv[2][:-4]}0 {delta.seconds}")
