#!/bin/bash

# script to schedule queues downtime by Danilo and Marco.
# USAGE: qdown downtime_hour [limit_hours]
# Remember to decomment LSF badmin commands at the bottom of the script.
# They have been commented for safety reasons.

IFS=$'\n'

limit_hour=${2:-"9"}
limit_min=$(echo "$limit_hour * 60" | bc)
downtime_hour=$1 #"2023-05-04 19:00" #$(date '+%Y%m%d')
#echo "downtime minus 30 days: $(echo $downtime_hour | date '+%Y-%m-%d %H:%M:%S' -d"-$limit_hour hours")"

if [[ -z $downtime_hour ]];
then
	echo "ERROR: You must specify downtime_hour in this format: \"YYYY-mm-dd HH:MM\""
	exit
fi

echo "specified downtime_hour: $downtime_hour"

for queue in $(bqueues -o "queue_name runlimit" | tail -n +2);
do
	q_name=$(echo $queue | cut -d' ' -f1)
	q_limit=$(echo $queue | cut -d' ' -f2)

	if [[ "$q_limit" == '-' ]];
	then
		q_limit=9999
	fi

	q_limit_hr=$(printf "%2.2f" $(echo "$q_limit/60" | bc -l));
	q_limit_min=$(echo "$q_limit_hr * 60" | bc | cut -d'.' -f1)

	#echo "$q_name : $q_limit_hr hr $q_limit_min min"

	if [[ $q_limit_min -gt $limit_min ]];
	then
		q_limit_min=$limit_min
	fi

	echo "$q_name : $q_limit_hr hr $q_limit_min min"

	queue_downtime=$(date -d "- $q_limit_min minutes $downtime_hour" '+%Y-%m-%d %H:%M') # | date '+%Y%m%d%H%M') 
	echo "$q_name downtime: $queue_downtime"
	queue_downtime_flat=$(date -d "$queue_downtime" '+%Y%m%d%H%M')
	echo "downtime_flat: $queue_downtime_flat"
	
	## Decomment these lines at your own risk!!
	#echo "badmin qclose $q_name" | at -t $queue_downtime_flat
	#echo "badmin qinact $q_name" | at -t $queue_downtime_flat


done

