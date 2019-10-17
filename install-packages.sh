#!/usr/bin/env bash

# Description: Install NGINX, MySQL and PHP on Debian-based distros
#      Author: Nasso Vikos <nas@vks.io>

set -o nounset

packages="nginx mysql-server php-fpm php-mysql"
user=$(whoami)

# Check whether user has permission to install packages
if [[ $user != "root" ]]; then
  echo -e "\\n[ EXIT ] This script must be run as root.\\n"
  exit 1
fi

# Check if NGINX, MySQL and PHP installed else install
for package in $packages; do
  package_status=$(dpkg-query --show --showformat='${db:Status-Status}' "$package")
  if [[ $? -eq 0 ]] && [[ $package_status == "installed" ]]; then
    echo -e "[  OK  ] Package $package is installed.\\n"
  elif [[ $? -eq 1 ]]; then
    echo "[ WAIT ] Package $package is not installed. Installing..."
    echo "" # Space output to improve output readability
    apt-get -y install "$package"
    if [[ $? -eq 0 ]]; then
      echo -e "[  OK  ] Package $package has been installed.\\n"
    else
      echo -e "[ FAIL ] Package installation failed.\\n"
      exit 1
    fi
  else
    echo -e "[ FAIL ] Error querying package status.\\n"
    exit 1
  fi
done

exit 0
