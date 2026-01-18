#!/usr/bin/bash

set -eu

sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f} || true # тут, вероятно, код возврата будет отличен от 0, т.к. при первичном добавлении для каждого диска вылетает сообщение "mdadm: Unrecognised md component device - /dev/sd*"; но я не проверял

sudo mdadm --create --verbose /dev/md0 -l 5 -n 5 /dev/sd{b,c,d,e,f}
