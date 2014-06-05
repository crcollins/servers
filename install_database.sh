#!/usr/bin/env bash

sudo apt-get update

sudo tee /etc/bash.bashrc <<EOF
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
EOF

sudo apt-get install -y postgresql

sudo -u postgres createdb mydb
sudo -u postgres createuser myuser -ws
sudo -u postgres psql -U postgres -d postgres -c "alter user myuser with password 'vagrant';"