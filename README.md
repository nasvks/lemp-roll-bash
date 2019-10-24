# lemp-roll
An NGINX, MySQL and PHP install and clean up script for Debian-based distros

## Usage
Execute ``sudo bash run.sh roll`` to install packages specified in run.conf or ``sudo bash run.sh unroll`` to remove them. Additional packages can be installed by adding them to the run.conf file.

## Testing
A Vagrantfile has been included to make testing the script a little easier. Follow the instructions below to make use of it.

1. ``sudo apt-get install vagrant`` to install Vagrant
2. ``sudo git clone https://github.com/nasvks/lemp-roll.git`` to clone the repository
3. ``vagrant up`` to boot the virtual machine
4. ``vagrant ssh`` to login to the virtual machine
5. ``sudo bash /vagrant/run.sh roll`` to install packages

## Todo 
* Secure access to the virtual machine using ufw
* Install Let's Encrypt to enable HTTPS for the web service
* Install the latest copy of Wordpress
* Figure out how best to configure NGINX, MySQL and PHP for Wordpress

## Disclaimer

This is the first Git repository that I created after completing the Atlassian [Version Control with Git](https://www.coursera.org/learn/version-control-with-git) course on Coursera. Drop me an [email](mailto:nas@vks.io) if you'd like to suggest an improvement to the way in which I've used Github.
