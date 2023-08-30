#!/bin/bash

########################################
#
# Automated script to remove logs from 2 weeks to 1 month old from todays date
#		- Search, Compress, Remove old logs
#

USER=admin
if [ "$(whoami)" != "${USER}" ]; then

        echo "Script must be run as user: ${USER}"
        exit -1
fi

printf "job is starting\n"

### Testing -- #TODO: LOGDIR=/var/logs/PATH
path='/c/Users/sammy/Documents/logs/'

echo "the date is: $(date +%Y-%m-%d)"
cd $path

echo "Current directory is: $(pwd)"

#Search the path for logs named: type.log.xz, app.log.xz, etc.. 
printf "job is searching\n"

	#OLDLOGS=($(find ${LOGDIR} \( -name "type.log.*" -or -name "app.log.*" -or -name "stats.log.*" \) ! -name "*.[gx]z" -mmin +119 ))

	#MAXPROCS=4
	#SLICELEN=$(( ${#OLDLOGS[@]} / ${MAXPROCS} + 1 ))

	#for (( i=1; i<=${MAXPROCS}; i++ ))

-exec "ls -lah | grep *2023-0[1-3]";

printf "\nremoved files from Jan-March\n"
# find the olds ones and put them in a list-variable

# loop through that list and remove from path

# return complete
printf "job complete.\n"
