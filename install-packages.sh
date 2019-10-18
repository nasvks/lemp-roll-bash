#!/usr/bin/env bash

# Description: Install NGINX, MySQL and PHP on Debian-based distros
#      Author: Nasso Vikos <nas@vks.io>

set -o nounset

packages="nginx mysql-server php-fpm php-mysql"
user=$(whoami)
filename=$(basename "$0" .sh)
log="$filename.log"

echo ""

# Check whether user has permission to install packages
if [[ $user != "root" ]]; then
  echo -e "[ EXIT ] This script must be run as root.\\n"
  exit 1
fi

# Update the package index
echo -e "[ WAIT ] Package index is being updated.\\n"
apt-get update &>> "$log"
if [[ $? -eq 0 ]]; then
 echo -e "[  OK  ] Package index has been updated.\\n"
else
 echo -e "[ FAIL ] Package index update failed. Review $log for details.\\n"
 exit 1
fi

# Check if NGINX, MySQL and PHP installed else install
for package in $packages; do
  package_status=$(dpkg-query --show --showformat='${db:Status-Status}' "$package" 2>> "$log" )
  if [[ $? -eq 0 ]] && [[ $package_status == "installed" ]]; then
    echo -e "[  OK  ] Package $package is installed.\\n"
  elif [[ $? -eq 1 ]]; then
    echo "[ WAIT ] Package $package is not installed. Installing..."
    echo "" # Space output to improve output readability
    apt-get -y install "$package" &>> "$log"
    if [[ $? -eq 0 ]]; then
      echo -e "[  OK  ] Package $package has been installed.\\n"
    else
      echo -e "[ FAIL ] Package installation failed. Review $log for details.\\n"
      exit 1
    fi
  else
    echo -e "[ FAIL ] Error querying package status. Review $log for details.\\n"
    exit 1
  fi
done

exit 0
