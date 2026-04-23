#!/bin/bash

set -eu

cp /vagrant/files/watchlog/watchlog.log /var/log/
chmod 644 /var/log/watchlog.log

cp /vagrant/files/watchlog/watchlog /etc/default/
chmod 644 /etc/default/watchlog

cp /vagrant/files/watchlog/watchlog.sh /opt/
chmod 755 /opt/watchlog.sh

cp /vagrant/files/watchlog/watchlog.service /etc/systemd/system/
chmod 644 /etc/systemd/system/watchlog.service

cp /vagrant/files/watchlog/watchlog.timer /etc/systemd/system/
chmod 644 /etc/systemd/system/watchlog.timer

systemctl daemon-reload
systemctl enable --now watchlog.timer
