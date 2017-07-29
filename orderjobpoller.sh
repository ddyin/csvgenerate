
#!/bin/bash

basedir=/opt/shells
cd /opt/shells
source $basedir/db.conf.sh
cat $basedir/orderjob.sql | $mysqlcli -N |
while IFS=$'\t' read oid jobId offsetOid
do
        args=("$jobId" "$oid" "$offsetOid")
                
                script=$basedir/orderjob.sh
                sh $script "${args[@]}"
done
