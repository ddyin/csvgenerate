SELECT 'recordAmount'
UNION ALL
SELECT COUNT(*)
FROM
   `t_money_publisher_investor_holdincome` t1,`t_gam_product` t2,t_gam_assetpool_income_allocate t3 
   WHERE t1.confirmDate ='#confirmDate' AND t1.productOid=t2.oid AND t1.incomeOid=t3.oid AND t1.productOid=t3.productOid AND t1.productOid='#productOid'

UNION ALL

SELECT 'productOid, investorOid, incomeAmount, confirmDate, beforeVolume, afterVolume,productType,averageRatio,averageWincome '
UNION ALL
SELECT 
  CONCAT( t1.productOid, ', ',
  t1.investorOid, ', ',
  TRUNCATE(t1.incomeAmount * 100, 0),', ',
  IFNULL(t1.confirmDate,''),', ',
  TRUNCATE(t1.accureVolume * 100, 0),', ',
  TRUNCATE((t1.accureVolume + t1.incomeAmount) * 100, 0), ', ',
  t2.type,', ',
  IFNULL(t3.averageRatio,''),', ',
  IFNULL(t3.averageWincome,''))
FROM
  `t_money_publisher_investor_holdincome` t1,`t_gam_product` t2,t_gam_assetpool_income_allocate t3 
   WHERE t1.confirmDate = '#confirmDate' AND t1.productOid=t2.oid AND t1.incomeOid=t3.oid AND t1.productOid=t3.productOid AND t1.productOid='#productOid' limit #incomestartIndex,#incomerows
