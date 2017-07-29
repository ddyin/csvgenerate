#!/bin/sh
echo "order script start!!!"

key=$1
condition=$2
offsetOid=$3
filetype=$key
basedir=/opt/shells

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
orderdatadir=$datadir/$today

source $basedir/db.conf.sh

myfiles=("customer_order_")
[ "$key" = "order" ] && myfiles=("customer_order_")

for x in ${myfiles[@]}
do

	if [ "$key" = "order" ];then
	#csv
        orderCount=`echo "SELECT COUNT(*) FROM t_money_investor_tradeorder t1,t_gam_product t2 WHERE t1.publisherOffsetOid ='$offsetOid' AND t1.productOid=t2.oid AND t1.orderType in ('normalRedeem','clearRedeem','cash','cashFailed')" | $mysqlcli -N -r | awk -F' ' '{print $1}' `
        ordersize=`echo "scale=6; $orderCount/50000" | bc`
        orderpages=`echo $ordersize | awk '{print int($ordersize)==($ordersize)? int($ordersize):int($ordersize)+1}' `
        for((i=1;i<=$orderpages;i++));
        do
         [ -d $orderdatadir ] || mkdir -p $orderdatadir
         orderSQLfile="order_${batch}_${offsetOid}_$i.sql"
         orderCSVfile="${x}${batch}_${offsetOid}_$i.csv"
         if [ "$i" = "1" ];then
              orderstartIndex=0
              orderrows=50003
         else
              orderrows=50000
              orderstartIndex=$[($i - 1) * 50000+3]
         fi
            sed -e "s/#offsetOid/$offsetOid/g" -e "s/#orderstartIndex/$orderstartIndex/g" -e "s/#orderrows/$orderrows/g" $basedir/order.temp.sql >$orderdatadir/$orderSQLfile
            $mysqlcli -N -r < $orderdatadir/$orderSQLfile >$orderdatadir/$orderCSVfile
            cat $orderdatadir/$orderSQLfile
        done
	notifyContent={'"'fileType'"':'"'order'"','"'fileName'"':'"'$orderCSVfile'"','"'fileDate'"':'"'$fileDate'"','"'filePath'"':'"'$orderdatadir'/"'}
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
echo "order script finished!!!"
echo -e "\n"