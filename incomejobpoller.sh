#!/bin/bash

basedir=/opt/shells
cd /opt/shells
source $basedir/db.conf.sh
cat $basedir/incomejob.sql | $mysqlcli -N |
while IFS=$'\t' read oid jobId createTime args
do
        args=("$jobId" "$oid" "$createTime" "$args")
                script=$basedir/incomejob.sh
                sh $script "${args[@]}"
done
