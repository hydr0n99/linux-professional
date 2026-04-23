#!/bin/bash

set -eu

apt-get update
apt install spawn-fcgi php php-cgi php-cli apache2 libapache2-mod-fcgid -y

mkdir -p /etc/spawn-fcgi/
cp /vagrant/files/spawn-fcgi/fcgi.conf /etc/spawn-fcgi/
chmod 644 /etc/spawn-fcgi/fcgi.conf

cp /vagrant/files/spawn-fcgi/spawn-fcgi.service /etc/systemd/system/
chmod 644 /etc/systemd/system/spawn-fcgi.service

systemctl daemon-reload
systemctl enable --now spawn-fcgi
