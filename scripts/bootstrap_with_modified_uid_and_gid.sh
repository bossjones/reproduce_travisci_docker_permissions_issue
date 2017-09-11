#!/usr/bin/env bash

set -x

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${_DIR}/default.sh

apt-get update -y && \
apt-get install -y git && \
apt-get install -y build-essential libssl-dev libreadline-dev wget curl openssh-server && \
apt-get install -y gcc make linux-headers-$(uname -r) && \
apt-get install -y ca-certificates bash && \
apt-get install -y python-setuptools perl pkg-config software-properties-common python python-pip python-dev && \
easy_install --upgrade pip && easy_install --upgrade setuptools; pip install setuptools --upgrade && \
add-apt-repository ppa:git-core/ppa -y && \
apt-get update && \
apt-get install -yqq git && \
apt-get update && \
apt-get upgrade -y && \
apt-get install -y lsof strace && \
apt -y update && apt-get -y upgrade && \
apt -y install software-properties-common && \
apt-add-repository ppa:ansible/ansible && \
apt -y update && \
apt -y install ansible && \
apt-get install -y openssh-server cryptsetup build-essential libssl-dev libreadline-dev zlib1g-dev linux-source dkms nfs-common zip unzip tree screen vim ntp vim-nox

echo ${_USER}:${_USER} | chpasswd
groupmod -A ${_USER} wheel

# Install the ${_USER} insecure public SSH key.
mkdir /home/${_USER}/.ssh
curl -LsSo /home/${_USER}/.ssh/authorized_keys https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
chown -R ${_USER}:${_USER} /home/${_USER}/.ssh
chmod -R go-rwx /home/${_USER}/.ssh

# Give the ${_USER} user sudo privileges.
cat > /etc/sudoers.d/${_USER} <<-EOF
	${_USER} ALL=(ALL) NOPASSWD: ALL
EOF
chmod 0440 /etc/sudoers.d/${_USER}

#fix stuff
sed -i '/UsePAM/aUseDNS no' /etc/ssh/sshd_config
sed -i '/env_reset/aDefaults        env_keep += "SSH_AUTH_SOCK"' /etc/sudoers;
# # source: https://github.com/geekduck/packer-templates/blob/76fb94e4161cd21a30047205c77cefeb4b881f8d/Ubuntu16.04/scripts/base.sh
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=sudo' /etc/sudoers
sed -i -e 's/%sudo ALL=(ALL:ALL) ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers
adduser vagrant adm

date > /etc/vagrant_box_build_time

# cleanup
# source: https://github.com/geekduck/packer-templates/blob/76fb94e4161cd21a30047205c77cefeb4b881f8d/Ubuntu16.04/scripts/cleanup.sh
apt-get -y autoremove
apt-get -y clean

# Install docker now
# prereqs
apt-get update
apt-get install --no-install-recommends \
    apt-transport-https \
    curl \
    software-properties-common

# aufs support
apt-get install -y --no-install-recommends \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual

# Download and import Docker’s public key for CS packages:
curl -fsSL 'https://sks-keyservers.net/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e' | sudo apt-key add -

add-apt-repository \
   "deb https://packages.docker.com/1.12/apt/repo/ \
   ubuntu-$(lsb_release -cs) \
   main"

# source: https://www.ubuntuupdates.org/ppa/docker_new?dist=ubuntu-trusty ( so we can get 1.12.5 )
apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo sh -c "echo deb https://apt.dockerproject.org/repo ubuntu-trusty main \
> /etc/apt/sources.list.d/docker.list"
sudo apt-get update
sudo apt-get install ${DOCKER_PACKAGE_NAME}

apt-get update

apt-cache search ${DOCKER_PACKAGE_NAME}
apt-cache madison ${DOCKER_PACKAGE_NAME}
apt-get -y -o Dpkg::Options::="--force-confnew" install ${DOCKER_PACKAGE_NAME}=$DOCKER_VERSION

rm -f /usr/local/bin/docker-compose
curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > docker-compose
chmod +x docker-compose
mv docker-compose /usr/local/bin
docker-compose --version

usermod -a -G docker ${_USER}

# Finally, and optionally, let’s configure Docker to start when the server boots:
update-rc.d docker defaults

# ctop
sudo wget https://github.com/bcicen/ctop/releases/download/v0.6.0/ctop-0.6.0-linux-amd64 -O /usr/local/bin/ctop
sudo chmod +x /usr/local/bin/ctop

# other deps
sudo apt-get update
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev nodejs -y
sudo apt-get install -y libgdbm-dev libncurses5-dev automake libtool bison libffi-dev

# https://askubuntu.com/questions/21547/what-are-the-packages-libraries-i-should-install-before-compiling-python-from-so
sudo apt-get install -y build-essential \
libncursesw5-dev \
libreadline5-dev \
libssl-dev \
libgdbm-dev \
libc6-dev \
libsqlite3-dev tk-dev \
libbz2-dev

sudo apt-get build-dep -y python3.4

exit 0