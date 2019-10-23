#!/usr/bin/env bash

# Description: Remove Install NGINX, MySQL and PHP on Debian-based distros
#      Author: Nasso Vikos <nas@vks.io>

set -o nounset

packages="php-mysql php-fpm mysql-server nginx"
user=$(whoami)
filename=$(basename "$0" .sh)
log="$filename.log"

echo ""

# Check whether user has permission to install packages
if [[ $user != "root" ]]; then
  echo -e "[ EXIT ] This script must be run as root.\\n"
  exit 1
fi

# Check if NGINX, MySQL and PHP installed and remove or skip
for package in $packages; do
  package_status=$(dpkg-query --show --showformat='${db:Status-Status}' "$package" 2>> "$log" )
  if [[ $? -eq 0 ]] && [[ $package_status == "installed" ]]; then
    echo -e "[  OK  ] Package $package is installed. Removing...\\n"
    apt-get -y purge "$package" &>> "$log"
    if [[ $? -eq 0 ]]; then
      echo -e "[  OK  ] Package $package has been removed.\\n"
    else
      echo -e "[ FAIL ] Package removal failed. Review $log for details.\\n"
      exit 1
    fi
  elif [[ $? -eq 1 ]]; then
    echo -e "[ WAIT ] Package $package is not installed. Skipping...\\n"
  else
    echo -e "[ FAIL ] Error querying package status. Review $log for details.\\n"
    exit 1
  fi
done

# Run package clean up tasks
echo -e "[ WAIT ] Package dependencies are being removed. Cleaning...\\n"
apt-get -y autoremove &>> "$log"
if [[ $? -eq 0 ]]; then
  echo -e "[  OK  ] Package dependencies have been removed.\\n"
else
  echo -e "[ FAIL ] Package dependencies clean up failed. Review $log for details.\\n"
  exit 1
fi

#echo -e "[ WAIT ] Package installation files being removed. Cleaning...\\n"
#apt-get -y autoclean &>> "$log"
#if [[ $? -eq 0 ]]; then
#  echo -e "[  OK  ] Package installation files have been removed.\\n"
#else
#  echo -e "[ FAIL ] Package installation files clean up failed. Review $log for details.\\n"
#  exit 1
#fi

exit 0
