#!/bin/bash

########################################
#
# Automated script to parse the command "ls -lah /../../archive/ logs"
#   - search for logs of a manually specified date and time and automatically #   generate new logs for the current date and time
# 

#local path
path='/c/users/sammy/Documents/logs'

#server path
###path='/export/home/archive'
cd $path

#Log output to parse-output.log
echo -e "\n####################################" >> parse-output.log
echo -e "####################################" >> parse-output.log
echo "Running parselogs.sh in $path" >> parse-output.log
echo -e "####################################\n" >> parse-output.log

today="$(date +%Y-%m-%d)"
echo "Current month date: $today"
echo -e " Date run: $today T:$(date +%T)\n\n" >> parse-output.log

#find the logs from longer than a month ago
# find $path -mtime +30  #-exec rm {} \;

#local path
source="/c/users/sammy/Documents/logs/app.log.*"
count=1

# array for type and app old logs to compress
result=( $(find ${source} \( -name "type.log.*" -or -name "app.log.*" \) )) #-mtime +30 ))

#server path
#run='ls -lah /export/home/archive/'

for files in $source
do
        len="${#source}"
        echo "Processing path source $files - $count/$len " >> parse-output.log
        ((count++))
done

echo "Completed - $count files found in $source. "
echo -e "=====================================\n"

num=1
for logs in $result
do 
	res_length=${#result[@]}
	echo "Processing result (find) $logs - $num / ${res_length}"
	((num++))
	#compress logs
	xz -1 ${result[@]} &
done

echo -e "Find command executed: processed $num files.\n\n"

echo "Testing find commands and flags++++++++++++"
echo -e "result: ${result[@]}" 

##This will find all files older than 15 days and print their names
# Check if logs are older than 30 days using -mtime +30
for (( i=1; i<=4; i++ ))
do 
	#echo "Array item: ${result[$i]}" # only displays position i, would need to loop over array itself to get each individual file
	# iterations are used due to xz CPU utilization being maxxed out, compressing several logs at a time instead of invidually
	echo "iteration: $i"
	COMP=("${result[@]::4}")
	echo "length of result: ${#result[@]}" 
	len=${#result}
	echo "Number of files: ${#COMP[@]}"
	result=("${result[@]:4:$len}")

	echo -e "TO Compress:\n ${COMP[@]}\n" >> parse-output.log
done

echo -e "\nJob Complete. Please see output logs in /logs/parse-output.log\n"
