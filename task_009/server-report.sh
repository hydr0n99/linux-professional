#!/bin/bash

set -euo pipefail

EMAIL="your@gmail.com"
SUBJECT="Hourly Server Report"

ACCESS_LOG="/var/log/nginx/access.log"
ERROR_LOG="/var/log/nginx/error.log"

STATE_DIR="$HOME/server-report"
LOCK_FILE="$STATE_DIR/server-report.lock"

TOP_LIMIT=3

mkdir -p "$STATE_DIR"

ACCESS_STATE="$STATE_DIR/access.offset"
ERROR_STATE="$STATE_DIR/error.offset"
LAST_RUN_FILE="$STATE_DIR/last_run"

exec 200>"$LOCK_FILE"
flock -n 200 || exit 0

NOW="$(date '+%Y-%m-%d %H:%M:%S %Z')"

if [[ -f "$LAST_RUN_FILE" ]]; then
    FROM="$(cat "$LAST_RUN_FILE")"
else
    FROM="-"
fi

TMP_ACCESS="$(mktemp)"
TMP_ERROR="$(mktemp)"
REPORT="$(mktemp)"

cleanup() {
    rm -f "$TMP_ACCESS" "$TMP_ERROR" "$REPORT"
}
trap cleanup EXIT

read_new_lines() {
    local log_file="$1"
    local state_file="$2"
    local output_file="$3"

    local total_lines last_line

    if [[ ! -f "$log_file" ]]; then
        echo "Log file not found: $log_file" > "$output_file"
        return
    fi

    total_lines="$(wc -l < "$log_file")"

    if [[ -f "$state_file" ]]; then
        last_line="$(cat "$state_file")"
    else
        last_line=0
    fi

    if [[ "$total_lines" -lt "$last_line" ]]; then
        last_line=0
    fi

    tail -n +"$((last_line + 1))" "$log_file" > "$output_file"

    echo "$total_lines" > "$state_file"
}

print_ips() {
    awk 'NF > 0 {print $1}' "$TMP_ACCESS" \
        | sort \
        | uniq -c \
        | sort -rn \
        | head -n "$TOP_LIMIT"
}

print_urls() {
    awk -F\" '{print $2}' "$TMP_ACCESS" \
        | awk 'NF >= 2 {print $2}' \
        | sort \
        | uniq -c \
        | sort -rn \
        | head -n "$TOP_LIMIT"
}

print_rcs() {
    awk -F\" '{print $3}' "$TMP_ACCESS" \
        | awk '$1 ~ /^[0-9][0-9][0-9]$/ {print $1}' \
        | sort \
        | uniq -c \
        | sort -rn \
        | head -n "$TOP_LIMIT"
}

print_errors() {
	awk '
		match($0, /\([0-9]+: [^)]*\)/) {
		print substr($0, RSTART, RLENGTH)
	}' "$TMP_ERROR" \
	| sort \
	| uniq -c \
	| sort -rn \
	| head -n "$TOP_LIMIT"
}
read_new_lines "$ACCESS_LOG" "$ACCESS_STATE" "$TMP_ACCESS"
read_new_lines "$ERROR_LOG" "$ERROR_STATE" "$TMP_ERROR"

{
    echo "Web Server Hourly Report"
    echo
    echo "Time Range:"
    echo "From: $FROM"
    echo "To:   $NOW"
    echo

    echo "Top IP Addresses"
    echo "-------------------------------"
    print_ips
    echo "-------------------------------"

    echo

    echo "Top Requested URLs"
    echo "-------------------------------"
    print_urls
    echo "-------------------------------"

    echo

    echo "Web Server Errors"
    echo "-------------------------------"
    print_errors
    echo "-------------------------------"

    echo

    echo "HTTP Response Codes"
    echo "-------------------"
    print_rcs
    echo "-------------------------------"

} > "$REPORT"

mail -s "$SUBJECT" "$EMAIL" < "$REPORT"

echo "$NOW" > "$LAST_RUN_FILE"
