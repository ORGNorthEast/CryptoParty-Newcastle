#!/bin/bash
set -eu
if [ $(id -g) != 0 ]; then echo "This script must be run as root." && exit 1; fi

# Create Nginx data dirs
mkdir -p "/usr/share/nginx/keys/"
mkdir -p "/usr/share/nginx/html/cryptopartynewcastle/"
mkdir -p "/usr/share/nginx/html/cryptopartynewcastle/www/"
mkdir -p "/usr/share/nginx/html/cryptopartynewcastle/forum/"
mkdir -p "/usr/share/nginx/html/cryptopartynewcastle/onionwww/"
mkdir -p "/usr/share/nginx/letsencrypt/"

# Set permissions for Nginx data dirs
chown -R www-data:www-data "/usr/share/nginx/" # Make sure regular user is a member of the www-data group
chmod -R 770 "/usr/share/nginx/"
