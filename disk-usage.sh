#!/bin/bash

#####################################
#
# Script created to automate checking disk space on servers
#

server=HOSTNAME
path="/export/home/tmp/"

#log onto each host as "user" - assign correct one before running script
ssh $server ("become user; ls; pwd;"

#run df -h /server-data/ for total disk usage
usecommand="df -h /server-data/"
diskuse="$(eval $usecommand)"

#run du -h /server-data/ | sort -h | grep tx for largest TX files
echo -e "Checking largest TX files"
usecommand-"du -h /server-data/ | sort -h | grep tx"
txfiles="$(eval $usecommand)" >> $path/disk-usage-tx.log


#run du -h /server-data/ | sort -h | grep chronicle for largest TX files
echo -e "Checking largest chronicleQueue files"
usecommand-"du -h /server-data/ | sort -h | grep chronicle"
cqfiles="$(eval $usecommand)" >> $path/disk-usage-cq.log


#if any files from yesterday are not compressed *.gz AND job has not run, compress if > than 90%
echo -e "Check the most recent files to confirm if they have been compressed."
echo -e "Below are TX Files: "
head -10 $path/disk-usage-tx.log
#output displays current date files for size reference

)
echo "Disk usage report complete."
