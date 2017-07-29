#!/bin/sh
echo "hold script start!!!"

key=$1
condition=$2
basedir=/opt/shells
holdStartConfirmDate=$(date +"%Y-%m-%d" -d '-4 day')
holdEndConfirmDate=$(date +"%Y-%m-%d")
holdStartTime="${holdStartConfirmDate} 00:00:00"
holdEndTime="${holdEndConfirmDate} 23:59:59"

[ $basedir == '.' ] && basedir=$PWD
datadir=$basedir/$key/data

# remove old files within one month
oldDate=$(date -d "last month" "+%Y%m%d")

echo "开始清除缓存一个月的文件"
if [ -d $datadir/$oldDate ];then
   rm -rf $datadir/$oldDate
   echo "完成删除动作"
   if [ -d $datadir/$oldDate ];then
     echo "删除失败"
   else
     echo "删除成功"
  fi
else
   echo "缓存一个月的文件目录不存在"
fi
echo "完成清除缓存一个月的文件"

today=`date +%Y%m%d`
fileDate=`date +%Y-%m-%d`
batch="`date +%Y%m%d%H%M00`"
datadir=$datadir/$today/$batch
source $basedir/db.conf.sh

myfiles=("customer_hold_")
[ "$key" = "hold" ] && myfiles=("customer_hold_")

for x in ${myfiles[@]}
do

        #hold
        if [ "$key" = "hold" ];then
        #csv

        holdCount=`echo "SELECT COUNT(*) FROM t_money_publisher_hold t1,t_gam_product t2  WHERE t1.productOid=t2.oid AND t1.updateTime >= '$holdStartTime' AND t1.updateTime <= '$holdEndTime' AND t1.accountType='INVESTOR'" | $mysqlcli -N -r | awk -F' ' '{print $1}' `
        size=`echo "scale=6; $holdCount/50000" | bc`
        pages=`echo $size | awk '{print int($size)==($size)? int($size):int($size)+1}' `
        for((i=1;i<=$pages;i++));
        do
         [ -d $datadir ] || mkdir -p $datadir
         holdSQLfile="hold_${batch}_$i.sql"
         holdCSVfile="${x}${batch}_$i.csv"
         if [ "$i" = "1" ];then
              startIndex=0
              rows=50003
         else
              rows=50000
              startIndex=$[($i - 1) * 50000+3]
         fi
           sed -e "s/#holdStartTime/$holdStartTime/g" -e "s/#holdEndTime/$holdEndTime/g" -e "s/#startIndex/$startIndex/g" -e "s/#rows/$rows/g" $basedir/hold.temp.sql >$datadir/$holdSQLfile
           $mysqlcli -N -r < $datadir/$holdSQLfile >$datadir/$holdCSVfile
           cat $datadir/$holdSQLfile
        done
        notifyContent={'"'fileType'"':'"'hold'"','"'fileName'"':'"'$holdCSVfile'"','"'fileDate'"':'"'$fileDate'"','"'filePath'"':'"'$datadir'/"'}
        echo -e "\n"
        else
                echo "no command execute"
                exit 0
        fi
        #lock table record
        sql="update t_money_job set jobStatus='finished' where oid='$condition' "
        $mysqlcli -e "$sql"

        #save notify
        notifyOiduuid=`cat /proc/sys/kernel/random/uuid`
        notifyoid=`echo $notifyOiduuid | sed 's/-//g'`
        notifyIduuid=`cat /proc/sys/kernel/random/uuid`
        notifyId=`echo $notifyIduuid | sed 's/-//g'`
        notifyDate=`date "+%Y-%m-%d %H:%M:%S"`
        sqlnotify="insert into t_money_platform_notify(oid,notifyId,notifyType,notifyContent,errorCode,notifyStatus,notifyTimes,seqId,updateTime,createTime) values('$notifyoid','$notifyId','documentExport','$notifyContent','0','toConfirm','0','0','$notifyDate','$notifyDate')"
        $mysqlcli -e "$sqlnotify"
done
echo "hold script finished!!!"
echo -e "\n"

