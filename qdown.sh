#!/bin/bash

# QDOWN SCHEDULER

# script to schedule queues downtime by Danilo and Marco.
# USAGE: qdown downtime_hour [limit_hours]
# Remember to decomment LSF badmin commands at the bottom of the script.
# They have been commented for safety reasons.


# LSF's Environment Source
##################################################################################
#export LSF_SERVERDIR=/opt/ibm/lsfsuite/lsf/10.1/linux2.6-glibc2.3-x86_64/etc
#export LSF_LIBDIR=/opt/ibm/lsfsuite/lsf/10.1/linux2.6-glibc2.3-x86_64/lib
#export LSF_VERSION=10.0
#export LSF_BINDIR=/opt/ibm/lsfsuite/lsf/10.1/linux2.6-glibc2.3-x86_64/bin
#export LSF_ENVDIR=/opt/ibm/lsfsuite/lsf/conf/


#export PATH=/opt/xcat/bin:/opt/xcat/sbin:/opt/xcat/share/xcat/tools:/usr/share/Modules/bin:/opt/ibm/lsfsuite/lsf/10.1/linux2.6-glibc2.3-x86_64/etc:/opt/ibm/lsfsuite/lsf/10.1/linux2.6-glibc2.3-x86_64/bin:/opt/ibm/lsfsuite/ext/perf/1.2/bin:/usr/bsd:/usr/ucb:/opt/ibm/lsfsuite/ext/ppm/10.2/bin:/opt/ibm/lsfsuite/ext/ppm/10.2/linux2.6-glibc2.3-x86_64/bin:/opt/ibm/lsfsuite/ext/gui/3.0/wlp/bin:/opt/ibm/lsfsuite/ext/gui/3.0/bin:/opt/ibm/lsfsuite/ext/ppm/10.2/bin:/opt/ibm/lsfsuite/ext/ppm/10.2/linux2.6-glibc2.3-x86_64/bin:/opt/lenovo/onecli:/opt/ibm/jre/bin:/opt/confluent/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/usr/lpp/mmfs/bin:/juno/opt/tools/bin:/bin:/usr/bin:/bin:/usr/bin:/root/bin

#source /etc/profile.d/lsf.sh
##################################################################################

IFS=$'\n'

limit_hour=${2:-"9"}
limit_min=$(echo "$limit_hour * 60" | bc)
downtime_hour=$1 #"2023-05-04 19:00" #$(date '+%Y%m%d')
#echo "downtime minus 30 days: $(echo $downtime_hour | date '+%Y-%m-%d %H:%M:%S' -d"-$limit_hour hours")"

CLUSTER_NAME=${3:-"JUNO"}
# Mail configuration
MAIL_CMD=${4:-"sendmail"}
MAIL_TO=${5:-"marco_chiarelli@yahoo.it"}
MAIL_FROM=${6:-"scc-noreply@cmcc.it"}
#

if [[ -z $downtime_hour ]];
then
	echo "ERROR: You must specify downtime_hour in this format: \"YYYY-mm-dd HH:MM\""
	exit
fi

echo "specified downtime_hour: $downtime_hour"

timetable='<table><br><tr style=\"color: black; font-weight: bold,italic; background-color: gray;\"><th>Queue</th><th>Scheduled Closing-Inactivating</th></tr><br>'

#prova=("p_short 540.0" "s_long 360.0")

for queue in ${prova[@]}; #$(bqueues -o "queue_name runlimit" | tail -n +2);
do
	q_name=$(echo $queue | cut -d' ' -f1)
	q_limit=$(echo $queue | cut -d' ' -f2)
	
	#echo "PRE Q_NAME $q_name PRE Q_LIMIT $q_limit"

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
	
	#echo "./qdown_child.sh $q_name $MAIL_CMD $MAIL_TO $MAIL_FROM" | at -t $queue_downtime_flat #$queue_downtime_flat ""$queue_downtime" | at -t queue_downtime_flat
	
	timetable="$timetable <tr><td><b>$q_name</b></td><td><i>$queue_downtime</i></td></tr>"
	## Decomment these lines at your own risk!!
	#echo "badmin qclose $q_name" | at -t $queue_downtime_flat
	#echo "badmin qinact $q_name" | at -t $queue_downtime_flat


done

timetable="$timetable <br></table>"


if [[ ! -z $MAIL_CMD ]] && [[ ! -z $MAIL_TO ]];
then
	(
        echo "Subject: [$CLUSTER_NAME - qdown.sh] Queues Closing-Deactivating - Scheduling Information";
        echo "From: $MAIL_FROM";
        echo "To: $MAIL_TO";
        echo "Content-Type: multipart/related; boundary=\"boundary-example\"; type=\"text/html\"";
        echo "";
        echo "--boundary-example";
        echo "Content-Type: text/html; charset=ISO-8859-15";
        echo "Content-Transfer-Encoding: 7bit";
        echo "";
        echo "<html><style>table, th, td { border:1px solid black; } th, td { padding: 5px; } th { background-color: lightgray } </style><head><meta http-equiv=\"content-type\" content=\"text/html; charset=ISO-8859-15\"></head><body>Dear $CLUSTER_NAME Admins,<br>This is to inform you that, due to the Scheduled Downtime of <i>$downtime_hour</i>, the following queues: <br> $timetable <br> will be closed and inactivated for maintenance activities.<br><br><br>Best Regards,<br>Marco Chiarelli & Danilo Mazzarella.</body></html>";
    ) | "$MAIL_CMD" -t "$MAIL_TO"
fi

