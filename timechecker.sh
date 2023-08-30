#!/bin/bash

########################################
# 
# Automated time checker to compare server time to timezones actual time
#

echo -e "#######################\n Time Checker "
echo -e "#######################\n"

current="$(date +%T) $(date +%Z)"
actual="Computer.time CDT"
echo "Current server time is: $current"

tz="$(systeminfo | grep 'Time Zone')"
slice=${tz::12}
len=${#tz}
echo -e "Actual time is: $actual in \n ${tz:12:$len} \n\n" 

