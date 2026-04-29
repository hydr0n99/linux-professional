#!/bin/bash

set -eu

CORE_TO_RUN_ON=2

NICE_1="-5"
NICE_2="5"

taskset -c $CORE_TO_RUN_ON nice -n $NICE_1 python3 run_me_1.py > 1.txt &
taskset -c $CORE_TO_RUN_ON nice -n $NICE_2 python3 run_me_2.py > 2.txt &

wait