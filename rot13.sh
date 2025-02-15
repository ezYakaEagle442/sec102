#!/bin/bash


### Log Function ###
log() {
    echo "`date +"%b %e %H:%M:%S"` S01[$$]:" $* | tee -a $LOG_FILE
}


echo "Have you read carefully the README file ?[Y/N]: \n"
read READ_CHECK
echo ""

# bash setEnv.sh

if [ "${READ_CHECK}" = 'y' ] || [ "${READ_CHECK}" = 'Yes' ]; then

	log TP02 START
	
	
	log TP02 END
	
else
	echo "You should read carefully the README file ... "
fi


# exit $?
