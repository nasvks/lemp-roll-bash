# lemp-roll
A script used to install or remove packages on Debian-based distros

## Usage
Execute ``sudo bash run.sh roll`` to install all packages specified in run.conf or ``sudo bash run.sh unroll`` to remove them.

## Testing
A Vagrantfile has been included to make testing the script a little easier. Follow the instructions below to make use of it.

1. Run ``sudo apt-get install vagrant`` to install Vagrant
2. Run ``sudo git clone https://github.com/nasvks/lemp-roll.git`` to clone the repository
3. Run ``vagrant up`` to boot the virtual machine
4. Run ``vagrant ssh`` to login to the virtual machine

## Todo
* Secure access to the virtual machine using ufw
* Install Let's Encrypt to enable HTTPS for the web service
* Install the latest copy of Wordpress
* Figure out how best to configure NGINX, MySQL and PHP for Wordpress
