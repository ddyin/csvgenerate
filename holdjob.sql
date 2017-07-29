select oid,jobId
from T_MONEY_JOB
WHERE jobStatus in ('toRun') AND jobId in ('hold');
