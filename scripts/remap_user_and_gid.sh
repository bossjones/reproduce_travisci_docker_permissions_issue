#!/usr/bin/env bash

set -x

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${_DIR}/default.sh

usermod -u ${_NON_ROOT_USER_UID} ${_USER}
groupmod -g ${_NON_ROOT_USER_GID} ${_USER}
usermod -g ${_NON_ROOT_USER_GID} ${_USER}
find / -uid ${_NON_ROOT_USER_UID_OLD} -exec chown ${_USER} {} \;
find / -gid ${_NON_ROOT_USER_GID_OLD} -exec chgrp ${_USER} {} \;

sed -i "s,${_USER}:x:${_NON_ROOT_USER_UID_OLD}:${_NON_ROOT_USER_GID_OLD}::/home/${_USER}:/bin/bash,${_USER}:x:${_NON_ROOT_USER_UID}:${_NON_ROOT_USER_GID}::/home/${_USER}:/bin/bash," /etc/passwd

reboot
