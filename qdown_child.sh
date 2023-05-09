#!/bin/bash

# QDOWN CHILD

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

q_name=$1
#queue_downtime_flat=$2
#queue_downtime=$3
CLUSTER_NAME=$2
MAIL_CMD=$3 #"sendmail"
MAIL_TO=$4 #"marco_chiarelli@yahoo.it"
MAIL_FROM=$5 #"scc-noreply@cmcc.it"

if [[ -z $q_name ]]; #|| [[ -z $queue_downtime_flat ]] || [[ -z $queue_downtime ]];
then
	echo "ERROR: You have to specify queue name, queue downtime datetime and the relative human-formatted version."
	echo "You must specify downtime_hour in this format: \"YYYY-mm-dd HH:MM\""
	exit 1
fi

#badmin qclose $q_name
#badmin qinact $q_name

if [[ ! -z $MAIL_CMD ]] && [[ ! -z $MAIL_TO ]];
then
	(
        echo "Subject: [$CLUSTER_NAME - qdown.sh] Queue $q_name\" Status modification";
        echo "From: $MAIL_FROM";
        echo "To: $MAIL_TO";
        echo "Content-Type: multipart/related; boundary=\"boundary-example\"; type=\"text/html\"";
        echo "";
        echo "--boundary-example";
        echo "Content-Type: text/html; charset=ISO-8859-15";
        echo "Content-Transfer-Encoding: 7bit";
        echo "";
        echo "<html><head><meta http-equiv=\"content-type\" content=\"text/html; charset=ISO-8859-15\"></head><body>Dear $CLUSTER_NAME Admins,<br>This is to inform you that the LSF queue <b>$q_name</b> has been closed and inactivated at <i>$(date)</i>.<br><br><br>Best Regards,<br>Marco Chiarelli & Danilo Mazzarella.</body></html>";
    ) | "$MAIL_CMD" -t "$MAIL_TO"
fi

# sendmail
