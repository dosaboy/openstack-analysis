#!/bin/bash
HOST=${1:-""}
for host in $(ls graphs); do
    if [[ -n $HOST ]]; then
        [[ $HOST == $host ]] || continue
    fi
    find graphs/$host -name \*.png| xargs firefox
done
