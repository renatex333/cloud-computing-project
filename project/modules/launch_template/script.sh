#!/bin/bash

# Absolute path to the Django project directory
PROJECT_DIR="/home/bitnami/project"

# Create the project directory
mkdir -p "$PROJECT_DIR"

# Create a new Django project
/opt/bitnami/python/bin/django-admin startproject project "$PROJECT_DIR"

# Path to Django main App
MAIN_APP_DIR="$PROJECT_DIR/project"

# Path to your Django settings.py file
SETTINGS_FILE="$MAIN_APP_DIR/settings.py"

# Check if the ALLOWED_HOSTS setting exists in the file
if grep -q "ALLOWED_HOSTS" "$SETTINGS_FILE"; then
    # Use sed to change the ALLOWED_HOSTS setting
    sed -i "s/ALLOWED_HOSTS *= *.*/ALLOWED_HOSTS = ['*']/" "$SETTINGS_FILE"
    echo "ALLOWED_HOSTS set to ['*'] in $SETTINGS_FILE."
else
    echo "ALLOWED_HOSTS setting not found in $SETTINGS_FILE."
fi

# Path to Django manage.py file
MANAGE_PY="$PROJECT_DIR/manage.py"

# Start a new Django app
cd "$PROJECT_DIR"
APP_NAME="ponnens"
/opt/bitnami/python/bin/python "$MANAGE_PY" startapp "$APP_NAME"
cd /

# Path to Django App
APP_DIR="$PROJECT_DIR/$APP_NAME"

# Check if the app is already in INSTALLED_APPS
if grep -q "'$APP_NAME'" "$SETTINGS_FILE"; then
    echo "App '$APP_NAME' is already in INSTALLED_APPS."
else
    # Use sed to append the app name to INSTALLED_APPS
    sed -i "/INSTALLED_APPS = \[/a \    '$APP_NAME'," "$SETTINGS_FILE"
    echo "Added '$APP_NAME' to INSTALLED_APPS in $SETTINGS_FILE."
fi

# Get IP address of the machine
PRIMARY_INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n 1)

IP_ADDR=$(ip addr show "$PRIMARY_INTERFACE" | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

# Create a new views.py file
echo "from django.http import HttpResponse


def index(request):
    return HttpResponse('Olá mundo! Este é a aplicação de IP: $IP_ADDR')
" > "$APP_DIR/views.py"

# Create a new urls.py file
echo "from django.urls import path

from . import views

urlpatterns = [
    path('', views.index, name='index'),
]
" > "$APP_DIR/urls.py"

# Add new app url to the project urls.py file
echo "from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('ponnens.urls')),
]
" > "$PROJECT_DIR/project/urls.py"

# Change DEBUG to False
sed -i "s/DEBUG = True/DEBUG = False/" "$SETTINGS_FILE"

# Final migration and runserver
/opt/bitnami/python/bin/python "$MANAGE_PY" makemigrations
/opt/bitnami/python/bin/python "$MANAGE_PY" migrate
/opt/bitnami/python/bin/python "$MANAGE_PY" runserver 0.0.0.0:8000