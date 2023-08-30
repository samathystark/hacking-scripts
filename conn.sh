#!/bin/bash

#####################################
#
# Checking network connectivity
# 

input=ntpstat
output=$(eval "$input")

# ntpstat parse through to find how many ms time is off
echo "Parsing starts.." 

ms=$output[@]

echo -e "output: $output --- \n ms: $ms" 

#if 

i=1

echo -e "iteration: $i - \n PARSE: ${output[$i]::2}" 
