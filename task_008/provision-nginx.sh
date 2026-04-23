#!/bin/bash

set -eu

apt-get update
apt install nginx -y

cp /vagrant/files/nginx/nginx@.service /etc/systemd/system/
chmod 644 /etc/systemd/system/nginx@.service 

cp /vagrant/files/nginx/nginx-first.conf /etc/nginx/
chmod 644 /etc/nginx/nginx-first.conf

cp /vagrant/files/nginx/nginx-second.conf /etc/nginx/
chmod 644 /etc/nginx/nginx-second.conf

systemctl start nginx@first
systemctl start nginx@second
