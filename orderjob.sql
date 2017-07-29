select oid,jobId,offsetOid
from T_MONEY_JOB
WHERE jobStatus in ('toRun') AND jobId in ('order');
