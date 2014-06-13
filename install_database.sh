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

if [ "$1" == "master" ];
    then
    sudo -u postgres psql -c "CREATE USER rep REPLICATION LOGIN CONNECTION LIMIT 1 ENCRYPTED PASSWORD 'vagrant';"
    sudo -u postgres -H sh -c 'ssh-keygen -b 2048 -f /var/lib/postgresql/.ssh/id_rsa -t rsa -q -N ""'
    sudo -u postgres -H sh -c 'echo "StrictHostKeyChecking no\n" >> /var/lib/postgresql/.ssh/config'
    sudo cp /var/lib/postgresql/.ssh/id_rsa.pub /vagrant

    sudo -u postgres -H sh -c 'ssh-keygen -b 2048 -f /var/lib/postgresql/slave_key -t rsa -q -N ""'
    sudo -u postgres -H sh -c 'cat /var/lib/postgresql/slave_key.pub >> /var/lib/postgresql/.ssh/authorized_keys'
    sudo cp /var/lib/postgresql/slave_key /vagrant
    sudo chmod 777 /vagrant/slave_key

    sudo /bin/sh -c 'echo "host replication rep 192.168.2.0/24 md5\n" >> /etc/postgresql/9.1/main/pg_hba.conf'
elif [ "$1" == "slave" ]
    then
    sudo -u postgres -H sh -c 'mkdir -p /var/lib/postgresql/.ssh'
    sudo -u postgres -H sh -c 'cat /vagrant/id_rsa.pub >> /var/lib/postgresql/.ssh/authorized_keys'
    sudo -u postgres -H sh -c 'echo "StrictHostKeyChecking no\n" >> /var/lib/postgresql/.ssh/config'

    sudo -u postgres -H sh -c 'cp /vagrant/slave_key /var/lib/postgresql/.ssh/id_rsa'
    sudo -u postgres -H sh -c 'chmod 600 /var/lib/postgresql/.ssh/id_rsa'

    sudo /bin/sh -c 'echo "host replication rep 192.168.2.200/32 md5\n" >> /etc/postgresql/9.1/main/pg_hba.conf'
fi

sudo sed -i -e "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/9.1/main/postgresql.conf

sudo tee -a /etc/postgresql/9.1/main/postgresql.conf <<EOF
wal_level = 'hot_standby'
archive_mode = on
archive_command = 'cd .'
max_wal_senders = 1
hot_standby = on
EOF

sudo /bin/sh -c 'echo "host all all 0.0.0.0/0 md5\nhost all all ::1/0 md5" >> /etc/postgresql/9.1/main/pg_hba.conf'

sudo service postgresql restart


if [ "$1" == "master" ];
    then
    sudo tee /vagrant/start_backup <<EOF
select pg_start_backup('initial_backup');
EOF
    sudo tee /vagrant/end_backup <<EOF
select pg_stop_backup();
EOF

elif [ "$1" == "slave" ]
    then
    sudo service postgresql stop

    sudo -u postgres -H sh -c 'ssh 192.168.2.200 "psql -f /vagrant/start_backup"'
    sudo -u postgres -H sh -c 'rsync -cva --inplace --exclude=*pg_xlog* 192.168.2.200:/var/lib/postgresql/9.1/main/ /var/lib/postgresql/9.1/main/'
    sudo -u postgres -H sh -c 'ssh 192.168.2.200 "psql -f /vagrant/end_backup"'

    sudo -u postgres -H sh -c "tee /var/lib/postgresql/9.1/main/recovery.conf <<EOF
standby_mode = 'on'
primary_conninfo = 'host=192.168.2.200 port=5432 user=rep password=vagrant'
trigger_file = '/tmp/postgresql.trigger.5432'
EOF"

    sudo service postgresql start
fi
