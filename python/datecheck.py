#!/usr/bin/python3
import sys
from datetime import datetime, timedelta


if __name__ == "__main__":
    _from = datetime.strptime(sys.argv[1], '%H:%M:%S')
    _to = datetime.strptime(sys.argv[2], '%H:%M:%S')
    delta = _to - _from
    if delta > timedelta():
        print(f"{sys.argv[2][:-4]}0 {delta.seconds}")
