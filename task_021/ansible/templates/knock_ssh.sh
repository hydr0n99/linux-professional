#!/bin/sh
set -eu

router="${1:-192.168.255.1}"
shift || true

knock "$router" 7000 8000 9000
sleep 1
exec ssh "vagrant@$router" "$@"
