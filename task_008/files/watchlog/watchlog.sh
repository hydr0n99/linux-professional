#!/bin/bash

set -eu

if [ $# -ne 2 ]; then
  echo "Usage: $0 <word> <logfile>"
  exit 1
fi

WORD="$1"
LOG="$2"

if [ ! -f "$LOG" ]; then
  echo "Log file not found: $LOG"
  exit 1
fi

if grep -qw "$WORD" "$LOG"; then
    logger -t log-monitor "$(date): Word $WORD was found!"
  else
    exit 0
fi
