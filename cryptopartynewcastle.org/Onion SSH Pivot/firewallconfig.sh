#!/bin/bash

if [ $(id -g) != 0 ]; then echo -e "This script must be run as root." && exit 1; fi

ufw disable
ufw reset

ufw default deny incoming
ufw default allow outgoing

ufw enable
