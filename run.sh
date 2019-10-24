#!/usr/bin/env bash

# Description: An NGINX, MySQL and PHP install and clean up script for Debian-based distros
#      Author: Nasso Vikos <nas@vks.io>

user=$(whoami)
filename=$(basename "$0" .sh)
log="$filename.log"
ip=$(ip route get 1 | head -n 1 | awk '{ print $7 }')
url="http://$ip:8080"

echo ""

# Check whether user has permission to install packages
if [[ $user != "root" ]]; then
  echo -e "[ EXIT ] This script must be run as root.\\n"
  exit 1
fi

# Check command line parameter
if [[ $1 == "roll" ]]; then

  # Update the package index
  echo -e "[ WAIT ] Package index is being updated.\\n"
  apt-get update &>> "$log"
  if [[ $? -eq 0 ]]; then
    echo -e "[  OK  ] Package index has been updated.\\n"
  else
    echo -e "[ EXIT ] Package index update failed. Review $log for details.\\n"
    exit 1
  fi

  # Check if NGINX, MySQL and PHP installed else install
  for package in $(cat run.conf); do
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
        echo -e "[ EXIT ] Package installation failed. Review $log for details.\\n"
        exit 1
      fi
    else
      echo -e "[ EXIT ] Error querying package status. Review $log for details.\\n"
      exit 1
    fi
  done

  # Check if NGINX and MySQL are running
  systemctl is-active mysql &>> /dev/null
  if [[ $? -eq 0 ]]; then
    echo -e "[  OK  ] Service MySQL is active.\\n"
  else
    echo -e "[ WAIT ] Service MySQL is inactive. Starting...\\n"
    systemctl start mysql &>> "$log"
    if [[ $? -eq 0 ]]; then
      echo -e "[  OK  ] Service MySQL is active.\\n"
    else
      echo -e "[ EXIT ] Service MySQL is inactive. Try to start it manually.\\n"
      exit 1
    fi
  fi

  systemctl is-active nginx &>> /dev/null
  if [[ $? -eq 0 ]]; then
    echo -e "[  OK  ] Service NGINX is active.\\n"
    echo -e "[ DONE ] You can access the web service at $url.\\n"
  else
    echo -e "[ WAIT ] Service NGINX is inactive. Starting...\\n"
    systemctl start nginx &>> "$log"
    if [[ $? -eq 0 ]]; then
      echo -e "[  OK  ] Service NGINX is active.\\n"
      echo -e "[ DONE ] You can access the web service at $url.\\n"
    else
      echo -e "[ EXIT ] Service NGINX is inactive. Try to start it manually.\\n"
      exit 1
    fi
  fi

elif [[ $1 == "unroll" ]]; then

  # Check if NGINX, MySQL and PHP installed and remove or skip
  for package in $(tac run.conf); do
    package_status=$(dpkg-query --show --showformat='${db:Status-Status}' "$package" 2>> "$log" )
    if [[ $? -eq 0 ]] && [[ $package_status == "installed" ]]; then
      echo -e "[  OK  ] Package $package is installed. Removing...\\n"
      apt-get -y purge "$package" &>> "$log"
      if [[ $? -eq 0 ]]; then
        echo -e "[  OK  ] Package $package has been removed.\\n"
      else
        echo -e "[ EXIT ] Package removal failed. Review $log for details.\\n"
        exit 1
      fi
    elif [[ $? -eq 1 ]]; then
      echo -e "[ WAIT ] Package $package is not installed. Skipping...\\n"
    else
      echo -e "[ EXIT ] Error querying package status. Review $log for details.\\n"
      exit 1
    fi
  done

  # Run package clean up tasks
  echo -e "[ WAIT ] Package dependencies are being removed. Cleaning...\\n"
  apt-get -y autoremove &>> "$log"
  if [[ $? -eq 0 ]]; then
    echo -e "[  OK  ] Package dependencies have been removed.\\n"
  else
    echo -e "[ EXIT ] Package dependencies clean up failed. Review $log for details.\\n"
    exit 1
  fi

else

  # Exit and display help
  echo -e "[ EXIT ] Execute 'run.sh roll' to install all packages in run.conf or 'run.sh unroll' to remove them.\\n"

fi

exit 0
