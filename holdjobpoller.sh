
#!/bin/bash

basedir=/opt/shells
cd /opt/shells
source $basedir/db.conf.sh
cat $basedir/holdjob.sql | $mysqlcli -N |
while IFS=$'\t' read oid jobId
do
        args=("$jobId" "$oid")
                script=$basedir/holdjob.sh
                sh $script "${args[@]}"
done
