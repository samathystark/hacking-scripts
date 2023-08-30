#!/bin/bash

#####################################
#
# Check network time protocol on the server
#

#grab the date for logs
date=$(date +%Y%d%m)
recipients="samvoss.hj@gmail.com"
#ccsupport="support@company.com"

# check the ntpd connection
# parse ntpstat output
input=ntpstat
output=$(eval "$input")
echo -e "\n--------------------------- \nRunning time-sync "
echo -e "---------------------------"

#path for logging exists
path="/tmp"
# provide log in output for each check
echo -e "Please see logs in $path/time-sync.log-$date for details.\n"
echo "----------" 

ms=$output[@]
time=$(date +%T)

echo -e "\n\n#######################\n TIME CHECKER\n#######################" >> $path/time-sync.log-$date
echo -e "$date-$time: \noutput: $output ----- " >> $path/time-sync.log-$date

max=95

echo -e "Parsing build array...\n" >> $path/time-sync.log-$date
for ((i=33; i<=${max}; i++))
do
        #echo -e "iteration: $i \n"

        build=("${output[@]::$i}")

        out_len=${#output[@]}
        #echo -e "$i == ${build[$i]}"

        #PARSER i == 59-64, "time" added to build array
        if [[ $i -ge "59" ]] && [[  $i -le "64" ]]
        then
                n=$i
                ### INIT $SET
                set=${output:59:92}
        fi
done

#compare output and send email for WARN or CRITICAL
message=" "
message2="No other issues."
email="FALSE"

# IF EMPTY abort -- ERROR:
if [ -z "$set" ]; then
       $message="${message}ABORT - Variable is not set.
"
       $message2="ERROR: Building array error - Please check script for variable problems
"
       #send SCRIPT ERROR email
       echo -e "ERROR Status: VAR assignmnet issue in $ms"
       echo -e "ERROR Status: VAR assignmnet issue in $ms" >> $path/time-sync.log-$date
       #ERROR Email
       mail -s "NTP ERROR from $HOSTNAME" $recipients -c $ccsupport <<< "$message
NTP output: ${set[@]:1:31}
${message2}"
       email="TRUE"
       echo -e "Parsing email sent. \n++++++++++++++++++++++++++++\n"
       echo -e "Parsing email sent. \n++++++++++++++++++++++++++++\n" >> $path/time-sync.log-$date
else
	     # $SET is not empty
        echo -e "SET $set\n" >> $path/time-sync.log-$date
fi

#ERROR -- error with parsing output=NULL or missing details from server
# WARN -- if sync is off by more than "ms" - 30 seconds
# CRITICAL -- if sync if off by more than 1 minute
# PASS - No email raised
current="$(date +%T) $(date +%Z)"
echo -e "Current time: $current"
message="  Current time: ${current}
"

# localhost set: server
echo -e " SERVER: $HOSTNAME \n" >> $path/time-sync.log-$date
message="${message}  SERVER: $HOSTNAME - "

#83-89 should encapsulate the "46 ms"
ms=${set[@]:24:2}
#ms=<STATIC> // value for testing WARN 35889 MID 59999 HIGH 75754

ip=${output:27:29}
#ip="(...)" // value for testing empty IP from ntpstat
echo -e "~~ IP: $ip ~~"
echo -e "~~ IP: $ip ~~" >> $path/time-checker.log-$date


###IF NULL - Check log, SET variable should display full output
if [ "$ip" = "(...)" ]; then
      message="${message}- ERROR - - Sync is missing details from server.
"
      #parsing error may be due to missing IP from ntpstat
      message2="     >>>>>>>>>>>>>>>>>>>>>>>>>>>>
     ERROR: Please investigate connectivity, IP is missing - $ip value
>>>>>>>>>>>>>>>>>>>>>>>>>>>>
"
      #send ERROR email for NTP missing IP
      echo -e "ERROR Status: ntpstat missing details from server."
      echo -e "ERROR Status: ntpstat missing details from server." >> $path/time-checker.log-$date
      #ERROR Email
      mail -s "NTP ERROR from $HOSTNAME" -t $(recipients) -c $(ccsupport) <<< "$message
NTP  output: ${set[@]}
${message2}"
      email="TRUE"
      echo -e "ERROR email sent. \n++++++++++++++++++++++++++++\n"
      echo -e "ERROR email sent. \n++++++++++++++++++++++++++++\n" >> $path/time-checker.log-$date
else
        #$ms is NOT NULL
        message="${message} Current IP value: $ip  
"
echo -e "Time (ms): $ms" >> $path/time-checker.log-$date
fi

### IF NULL - Check logs, parsing issue still present
if [ -z "$ms" ]; then
	message="${message} 
                      >>>>>>>>>>>>>>>>>>>>>>>>>>>>
                        ERROR: Sync is NULL.    IP value: $ip
                      >>>>>>>>>>>>>>>>>>>>>>>>>>>>
"
        message2="     ERROR: Time sync parsing error - Please investigate script issues where time offset is NULL.
"
	      #send ERROR - Time-sync is NULL email
        echo -e "ERROR Status: time-sync parsing error by VALUE:$ms."
        echo -e "ERROR Status: time-sync parsing error by VALUE:$ms." >> $path/time-sync.log-$date
        #ERROR Email
        mail -s "NTP ERROR from $HOSTNAME" $recipients -c $ccsupport <<< "$message
NTP output: ${set[@]:1:31}
${message2}"
        email="TRUE"
        echo -e "Error email sent. \n++++++++++++++++++++++++++++\n"
        echo -e "Error email sent. \n++++++++++++++++++++++++++++\n" >> $path/time-sync.log-$date
else
        # $ms is NOT NULL
        message="${message}
Sync is at $ms ms
"
        echo -e "Time (ms): $ms" >> $path/time-sync.log-$date
fi

### How far off is the time?
if [ $ms -ge "30000" ] && [ $ms -le "59999" ]; then
       message="${message}      WARNING:  >>>>>>>>>>>>>>>>>>>>>>>>>>>>
                  Time sync is off by $ms - this may be a false positive. Check server to confirm and restart ntpd.
~~ Current IP: $ip ~~
"
       message2="   -WARN- Please investigate script issues where time offset is more than 30 seconds off.
"
       #send WARN email for time-sync offset by $ms
       echo -e "WARNING Status: time-sync offset by $ms."
       echo -e "WARNING Status: time-sync offset by $ms." >> $path/time-sync.log-$date
       #WARNING EMAIL
       mail -s "NTP WARNING from $HOSTNAME" $recipients -c $ccsupport <<< "$message
NTP output: ${set[@]:1:31}
${message2}"
       email="TRUE"
       echo -e "Warning email sent. \n++++++++++++++++++++++++++++\n"
       echo -e "Warning email sent. \n++++++++++++++++++++++++++++\n" >> $path/time-sync.log-$date

elif [[ $ms -ge "60000" ]]; then
       message="${message}       CRITICAL:  >>>>>>>>>>>>>>>>>>>>>>>>>>>>
                  Time sync is off by $ms - Raise incident and restart ntpd.
"
       message2="    --CRITICAL-- Please investigate script issues where time offset is too high over 60 seconds.
~~ Current IP: $ip ~~
"
       #send CRITICAL email for time-sync offset by $ms
       echo -e "CRITICAL Status: time-sync offset by $ms."
       echo -e "CRITICAL Status: time-sync offset by $ms." >> $path/time-sync.log-$date
       #CRITICAL EMAIL
       mail -s "NTP CRITICAL from $HOSTNAME" $recipients -c $ccsupport <<< "$message
NTP output: ${set[@]:1:31}
${message2}"
       email="TRUE"
       echo -e "Critical email sent. \n++++++++++++++++++++++++++++\n"
       echo -e "Critical email sent. \n++++++++++++++++++++++++++++\n" >> $path/time-sync.log-$date

fi

echo -e "The sync  ${set[@]:1:31} \n++++++++++++++++++++++++++++\n"

# Confirm email was sent, log EOL "+++'s" for reference
if [ $email = "FALSE" ]; then
       echo -e "\n++++++++++++++++++++++++++++\n" >> $path/time-sync.log-$date
fi

### Sync offset is: $ms ms
# possible issue that it will not trigger an error if larger than 3 digits since $ms is only 2 digits

## CRONTAB: 
#server01
##  0 * * * * cd /export/home/myScripts; ./time-checker.sh >> nohup.txt
#server02
##  0 * * * * cd /export/home/myScripts; ./time-checker.sh >> nohup.txt
