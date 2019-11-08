#!/usr/bin/env bash

# Description: An NGINX, MySQL and PHP install and clean up script for Debian-based distros
#      Author: Nasso Vikos <nas@vks.io>

stty -echo # Disable keyboard input echoing

user=$(whoami)
filename=$(basename "$0" .sh)
config="$filename.conf"
log="$filename.log"
ip=$(ip route get 1 | head -n 1 | awk '{ print $7 }')
url="http://$ip"

echo ""

# Check whether user has permission to install packages
if [[ $user != "root" ]]; then
  echo -e "[ EXIT ] This script must be run as root.\\n"
  stty echo; exit 1
fi

# Catch Ctrl-C key press
echo -e "[ INFO ] Hit Ctrl-C to break and quit (exit 2).\\n"
trap 'echo -e "[ EXIT ] Script terminated by user.\\n";
      stty echo;
      exit 2' INT

# Check command line parameter
if [[ $1 == "roll" ]]; then

  # Check whether firewall should be enabled
  if [[ $(grep ufw "$config" | cut -d "=" -f 2) == "enabled" ]]; then
    echo -e "[ WAIT ] Firewall is being configured. Configuring...\\n"
    ufw default deny incoming &> "$log" && \
    ufw allow 22,80 &>> "$log" && \
    ufw --force enable &>> "$log" && \
    sleep 3
    if [[ $? -eq 0 ]]; then
      echo -e "[  OK  ] Firewall configuration completed.\\n"
    else
      echo -e "[ EXIT ] Firewall configuration failed. Review $log for details.\\n"
      stty echo; exit 1
    fi
  else
    echo -e "[ INFO ] Skipping firewall configuration.\\n"
  fi

  # Perform basic Internet connectivity test
  ping -c 3 $(grep ping "$config" | cut -d "=" -f 2) &>> "$log"
  if [[ $? -eq 0 ]]; then
    echo -e "[  OK  ] Internet connectivity confirmed.\\n"
  else
    echo -e "[ EXIT ] Internet connectivity test failed. Check network connectivity.\\n"
    stty echo; exit 1
  fi

  # Update the package index
  echo -e "[ WAIT ] Package index is being updated. Updating...\\n"
  apt-get update &>> "$log"
  if [[ $? -eq 0 ]]; then
    echo -e "[  OK  ] Package index has been updated.\\n"
  else
    echo -e "[ EXIT ] Package index update failed. Review $log for details.\\n"
    stty echo; exit 1
  fi

  # Check whether packages are installed else install
  for package in $(cat "$config" | grep install | cut -d "=" -f 1); do
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
        stty echo; exit 1
      fi
    else
      echo -e "[ EXIT ] Error querying package status. Review $log for details.\\n"
      stty echo; exit 1
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
      echo -e "[ EXIT ] Service start failed. Try to start it manually.\\n"
      stty echo; exit 1
    fi
  fi

  systemctl is-active nginx &>> /dev/null
  if [[ $? -eq 0 ]]; then
    echo -e "[  OK  ] Service NGINX is active.\\n"
    if [[ $(logname) == "vagrant" ]]; then
      echo -e "[ INFO ] Access the web service at http://127.0.0.1:8080.\\n"
    else
      echo -e "[ DONE ] Access the web service at $url.\\n"
    fi
  else
    echo -e "[ WAIT ] Service NGINX is inactive. Starting...\\n"
    systemctl start nginx &>> "$log"
    if [[ $? -eq 0 ]]; then
      echo -e "[  OK  ] Service NGINX is active.\\n"
      if [[ $(logname) == "vagrant" ]]; then
        echo -e "[ INFO ] Access the web service at http://127.0.0.1:8080.\\n"
      else
        echo -e "[ DONE ] Access the web service at $url.\\n"
      fi
    else
      echo -e "[ EXIT ] Service start failed. Try to start it manually.\\n"
      stty echo; exit 1
    fi
  fi

elif [[ $1 == "unroll" ]]; then

  # Check whether packages are installed and remove or skip
  for package in $(tac "$config" | grep install | cut -d "=" -f 1); do
    package_status=$(dpkg-query --show --showformat='${db:Status-Status}' "$package" 2>> "$log" )
    if [[ $? -eq 0 ]] && [[ $package_status == "installed" ]]; then
      echo -e "[  OK  ] Package $package is installed. Removing...\\n"
      apt-get -y purge "$package" &>> "$log"
      if [[ $? -eq 0 ]]; then
        echo -e "[  OK  ] Package $package has been removed.\\n"
      else
        echo -e "[ EXIT ] Package removal failed. Review $log for details.\\n"
        stty echo; exit 1
      fi
    elif [[ $? -eq 1 ]]; then
      echo -e "[ INFO ] Package $package is not installed. Skipping...\\n"
    else
      echo -e "[ EXIT ] Error querying package status. Review $log for details.\\n"
      stty echo; exit 1
    fi
  done

  # Run package clean up tasks
  echo -e "[ WAIT ] Package dependencies are being removed. Cleaning...\\n"
  apt-get -y autoremove &>> "$log"
  if [[ $? -eq 0 ]]; then
    echo -e "[  OK  ] Package dependencies have been removed.\\n"
  else
    echo -e "[ EXIT ] Package dependencies clean up failed. Review $log for details.\\n"
    stty echo; exit 1
  fi

  # Deconfigure firewall
  ufw --force reset &>> "$log" && \
  ufw --force disable &>> "$log"
  if [[ $? -eq 0 ]]; then
    echo -e "[  OK  ] Firewall has been deconfigured.\\n"
  else
    echo -e "[ EXIT ] Firewall could not be deconfigured. Review $log for details.\\n"
    stty echo; exit 1
  fi

else

  # Exit and display help
  echo -e "[ EXIT ] Execute 'run.sh roll' to install all packages in run.conf or 'run.sh unroll' to remove them.\\n"
  stty echo; exit 1

fi

echo -e "[ DONE ] All tasks completed.\\n"

stty echo # Enable keyboard input echoing

exit 0
