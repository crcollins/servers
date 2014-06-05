#!/usr/bin/env bash

sudo apt-get update

sudo tee /etc/bash.bashrc <<EOF
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
EOF

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

sudo locale-gen en_US.UTF-8
sudo dpkg-reconfigure locales

sudo apt-get install -y postgresql

sudo -u postgres createdb mydb
sudo -u postgres createuser vagrant -ws
sudo -u postgres psql -U postgres -d postgres -c "alter user vagrant with password 'vagrant';"

sudo sed -i -e "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/9.1/main/postgresql.conf
sudo /bin/sh -c 'echo "host all all 0.0.0.0/0 md5\nhost all all ::1/0 md5" >> /etc/postgresql/9.1/main/pg_hba.conf'

sudo service postgresql restart
