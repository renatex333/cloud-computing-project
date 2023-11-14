#!/bin/bash
cd /home/bitnami/
git clone https://github.com/renatex333/P1B-TecWeb.git
cd P1B-TecWeb/
git checkout cloud
git pull
SETTINGS_FILE="getit/settings.py"
INDEX_FILE="notes/templates/notes/index.html"
HOSTNAME="${hostname}"
PASSWORD="modusponnens"
PRIMARY_INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n 1)
IP_ADDR=$(ip addr show "$PRIMARY_INTERFACE" | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
sed -i "s|<span class='subtitle'>Title</span>|<span class='subtitle'>$IP_ADDR</span>|" "$INDEX_FILE"
sed -i "s/'HOST': 'host'/'HOST': '$HOSTNAME'/" "$SETTINGS_FILE"
sed -i "s/'PASSWORD': 'password'/'PASSWORD': '$PASSWORD'/" "$SETTINGS_FILE"
/opt/bitnami/python/bin/python manage.py makemigrations
/opt/bitnami/python/bin/python manage.py migrate
/opt/bitnami/python/bin/python manage.py runserver 0.0.0.0:8000