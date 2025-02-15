!/bin/bash

set -x
### Declare variables ###
# http://www.epons.org/shell-bash-variables.php
# https://unix.stackexchange.com/questions/130985/if-processes-inherit-the-parents-environment-why-do-we-need-export
env -i
set -a

USERNAME=`whoami`
HOSTNAME=`hostname`

#WORK_DIR="/home/${USERNAME}"
WORK_DIR="."
LOG_FILE="${WORK_DIR}/${0}.log"

### Log Function ###
log() {
    echo "`date +"%b %e %H:%M:%S"` TP02 [$$]:" $* | tee -a $LOG_FILE    
}

log " USERNAME = ${USERNAME} "
log " HOSTNAME = ${HOSTNAME} "

#set +x
