#!/usr/bin/env bash

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${_DIR}/default.sh

sudo apt-get install -y git
sudo apt-get install -y make
sudo apt-get install -y libbz2-dev
sudo apt-get install -y libsqlite3-dev

if [ ! -f /var/log/pythonsetup ];
then
    git clone git://github.com/yyuu/pyenv.git /home/${_USER}/.pyenv
    chown ${_USER}:${_USER} .pyenv
    echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> /home/${_USER}/.bashrc
    echo 'eval "$(pyenv init -)"' >> /home/${_USER}/.bashrc

    # Can't source /home/${_USER}/.bashrc for some reason so repeat commands below
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"

    pyenv install ${_PYENV_PYTHON_VERSION}
    pyenv rehash

    touch /var/log/pythonsetup
fi
