#!/usr/bin/env bash

set -eu

cp /vagrant/login.sh /usr/local/bin/

useradd otusadm && useradd otus-user-1 && useradd otus-user-2
echo '12345678' | passwd --stdin otusadm \
    && echo '12345678' | passwd --stdin otus-user-1 \
    && echo '12345678' | passwd --stdin otus-user-2

groupadd -f admins
usermod root -a -G admins && usermod vagrant -a -G admins && usermod otusadm -a -G admins

echo "auth required pam_exec.so debug /usr/local/bin/login.sh" >> /etc/pam.d/sshd
