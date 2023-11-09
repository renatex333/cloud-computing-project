#!/bin/bash

django-admin startproject sample
python sample/manage.py migrate
python sample/manage.py runserver 0.0.0.0:8000

# Tem que botar ALLOWED_HOSTS = ['*'] ou [SERVER IP] no settings.py
