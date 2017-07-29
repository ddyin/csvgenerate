select oid,jobId,createTime,args
from T_MONEY_JOB
WHERE jobStatus in ('toRun') AND jobId in ('income');
