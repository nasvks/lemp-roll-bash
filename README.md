# lemp-roll-bash
An NGINX, MySQL and PHP install and clean up script for Debian-based distros

## Usage
Execute ``sudo bash run.sh roll`` to install packages specified in run.conf or ``sudo bash run.sh unroll`` to remove them. Additional packages can be installed by adding them to the run.conf file.

By default a very basic netfilter firewall is enabled and is configured to accepts traffic on ports 22/tcp and 80/tcp. To skip configuring the firewall, set ``ufw=disabled`` in run.conf.

## Testing
A Vagrantfile has been included to make testing the script a little easier. Follow the instructions below to make use of it.

1. ``sudo apt-get install vagrant`` to install Vagrant
2. ``sudo git clone https://github.com/nasvks/lemp-roll.git`` to clone the repository
3. ``vagrant up`` to boot the virtual machine
4. ``vagrant ssh`` to login to the virtual machine
5. ``sudo bash /vagrant/run.sh roll`` to install packages

## Todo 
* ~~Add a check for Internet connectivity~~
* ~~Secure access to the virtual machine using ufw~~
* ~~Add an option to hit Ctrl-C and exit gracefully~~
* Install Let's Encrypt to enable HTTPS for the web service
* Install the latest copy of Wordpress
* Figure out how best to configure NGINX, MySQL and PHP for Wordpress
* Create functions where applicable and refactor
