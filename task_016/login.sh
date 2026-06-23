#!/usr/bin/env bash

day=$(date +%u)

if [[ "$day" -ge 6 ]] && ! id -nG "$PAM_USER" | grep -qw admins; then
    exit 1
fi

exit 0
