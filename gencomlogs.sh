#!/bin/bash

########################################
#
# Automated script for generating logs and compressing them in one script. 
#   - Final version should be able to compress old files from anywhere from 2 #   weeks ago to 2 months ago. 
#   - GOAL: Be able to automatically generate logs for the current date at #   runtime and compress any old files from 5 days ago to test. 
#

#local path
path="/c/users/sammy/Documents/logs/"
cd $path

#Log output to parse-output.log
echo -e "\n####################################" >> gencom-output.log
echo -e "####################################" >> gencom-output.log
echo "Running gencomlogs.sh in $path" >> gencom-output.log
echo -e "####################################\n" >> gencom-output.log

today="$(date +%F)"
echo "Generating logs for $today..." >> gencom-output.log

### Automated script to create logs and compress them
#XXX TODO

#generate logs
stamp="$(date +%F)-T$(date +%T)"
month="$(date +%m)" 
echo "Created for $stamp" >> gencom-output.log
touch $path/newlog-$(date +%Y-%m-%d)-$month.log # --> ideal

#manual logs generated
name="March-2023-05"
touch oldLogs-$name-notCompressed.log
echo -e "Saved manual log: $name-notCompressed.log"

#local auto generated
touch app.log.$stamp-generated-com
touch type.log.$stamp-generated-com
touch metrics.log.$stamp-generated-com
#touch newlog-2023-$month-{1..20}-$stamp-generated.log
echo -e "Saved new automated logs. \n" >> gencom-output.log
#((counter++))
#echo -e "$counter loop(s).\n"

#find the logs from longer than a month ago
echo "FIND THE OLD LOGS ---> " 
#OLDLOGS=($("find ${path} \( -name "type.log.*" -or -name "metrics.log.*" -or -name "app.log.*" \) " )) # -type f .. -mtime +30 " )) #-exec rm {} \;
OLDLOGS=($(find $path -name "type.log.*" -or -name "metrics.log.*" -or -name "app.log.*"))

echo -e "Checking old logs... \n"
echo "$ Array: ${OLDLOGS[@]}"
MAX=4
parse=$(( ${#OLDLOGS[@]} / ${MAX} + 1 ))

total=1
for (( i=1; i<=${MAX}; i++ ))
do
        echo -e "$ (${OLDLOGS[@]}) \n"
        # Slice first few logs (elements) in of array @OLDLOGS
        complogs=("${OLDLOGS[@]::$parse}")
        # Length of array @OLDLOGS
        len="${#OLDLOGS[@]}"
	echo "i= $i with length: $len"
	#Print out the file/log in position $i of the array @OLDLOGS
        log="${OLDLOGS[$i]}"
	echo "i= $i with log[$i]: $log"
        #Remove first slice of logs in array @OLDLOGS (each pass will decrease the number of logs held in array)
        OLDLOGS=("${OLDLOGS[@]:$parse:$len}")

        #echo "Length: $len, Slice (parse): $parse, New Array length: ${#OLDLOGS[@]}"
        echo "File: $log out of $len" >> gencom-output.log
        ((total++))
        #echo -e "\n Iteration: $i"
        #echo -e "Files to xz: ${#complogs[@]}"

        #compress logs XXX TODO
        #echo "Compressing logs now.. "
		#xz -1 {$source[@]} &
done

#echo "Job Complete. "
echo "Please see output logs in /logs/gencom-output.txt"
