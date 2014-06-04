#!/usr/bin/env bash

INSTALL_USER=vagrant
PROJECT_DIR=/home/$INSTALL_USER/base_project
export PIP_DEFAULT_TIMEOUT=600

dependencies() {
    sudo apt-get update
    sudo apt-get install -y git python2.7 python-pip supervisor nginx
    sudo pip install virtualenv
}

install_base_project() {
    cd $PROJECT_DIR
    virtualenv .
    . bin/activate

    pip install -r requirements.txt
    python manage.py syncdb --noinput
}

setup_nginx() {
    cd $PROJECT_DIR
    . bin/activate
    sudo sed -e "s/\$INSTALL_USER/$INSTALL_USER/g"      \
             -e "s,\$PROJECT_DIR,$PROJECT_DIR,g"        \
             base_project/nginx_settings.conf           \
             | sudo tee /etc/nginx/sites-available/base_project
    sudo sed -e "s/\$INSTALL_USER/$INSTALL_USER/g"      \
             -e "s,\$PROJECT_DIR,$PROJECT_DIR,g"        \
             base_project/supervisor_settings.conf      \
             | sudo tee /etc/supervisor/conf.d/base_project.conf
    sudo ln -fs /etc/nginx/sites-available/base_project /etc/nginx/sites-enabled/base_project
    sudo rm -f /etc/nginx/sites-enabled/default
    sudo nginx -s reload

    sudo supervisorctl reread
    sudo supervisorctl update
    sudo service nginx restart
}

update() {
    cd $PROJECT_DIR
    . bin/activate
    git pull
    pip install -r requirements.txt
    python manage.py syncdb --noinput
    sudo supervisorctl restart base_project
}

remove() {
    sudo rm -rf $PROJECT_DIR /etc/nginx/sites-available/base_project \
                /etc/nginx/sites-enabled/base_project /etc/supervisor/conf.d/base_project.conf
    sudo supervisorctl shutdown base_project
    sudo service nginx restart
}



if [ "$1" == "remove" ];
    then
    echo "Uninstalling"
    remove
else
    dependencies
    install_base_project
    setup_nginx
fi