#!/bin/sh
echo "script start!!!"

key=$1
condition=$2
jobCreateTime=$3
productOid=$4
filetype=$key
basedir=/opt/shells
confirmDate=$(date +"%Y-%m-%d" -d '-1 day')
startTime="${confirmDate} 00:00:00"
endTime="${confirmDate} 23:59:59"

jobCreateTimes=`date -d "$jobCreateTime" +%s`
startTimes=`date -d "$startTime" +%s`
endTimes=`date -d "$endTime" +%s`

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
incomedatadir=$datadir/$productOid
source $basedir/db.conf.sh

myfiles=("customer_income_")
[ "$key" = "income" ] && myfiles=("customer_income_")



for x in ${myfiles[@]}
do

	#income
	if [ "$key" = "income" -a $jobCreateTimes -ge $startTimes -a $jobCreateTimes -le $endTimes ];then
	#csv  
        incomeCount=`echo "SELECT COUNT(*) FROM t_money_publisher_investor_holdincome t1,t_gam_product t2,t_gam_assetpool_income_allocate t3 WHERE t1.confirmDate >= '$startTime' AND t1.confirmDate <= '$endTime' AND t1.productOid=t2.oid AND t1.incomeOid=t3.oid AND t1.productOid=t3.productOid AND t1.productOid='$productOid'" | $mysqlcli -N -r | awk -F' ' '{print $1}' `
        incomesize=`echo "scale=6; $incomeCount/50000" | bc`
        incomepages=`echo $incomesize | awk '{print int($incomesize)==($incomesize)? int($incomesize):int($incomesize)+1}' `
        for((i=1;i<=$incomepages;i++));
        do
         [ -d $incomedatadir ] || mkdir -p $incomedatadir
         incomeSQLfile="income_${batch}_${productOid}_$i.sql"
         incomeCSVfile="${x}${batch}_${productOid}_$i.csv"
         if [ "$i" = "1" ];then
              incomestartIndex=0
              incomerows=50003
         else
              incomerows=50000
              incomestartIndex=$[($i - 1) * 50000+3]
         fi
            sed -e "s/#confirmDate/$confirmDate/g" -e "s/#productOid/$productOid/g" -e "s/#incomestartIndex/$incomestartIndex/g" -e "s/#incomerows/$incomerows/g" $basedir/income.temp.sql >$incomedatadir/$incomeSQLfile
            $mysqlcli -N -r < $incomedatadir/$incomeSQLfile >$incomedatadir/$incomeCSVfile
            cat $incomedatadir/$incomeSQLfile
        done
	notifyContent={'"'fileType'"':'"'income'"','"'fileName'"':'"'$incomeCSVfile'"','"'fileDate'"':'"'$fileDate'"','"'filePath'"':'"'$incomedatadir'/"'}
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
echo "script finished!!!"
echo -e "\n"

