SELECT 'recordAmount'
UNION ALL
SELECT COUNT(*)
FROM
  `t_money_publisher_hold` t1,`t_gam_product` t2  WHERE t1.productOid=t2.oid AND t1.updateTime >= '#holdStartTime' AND t1.updateTime <= '#holdEndTime' AND t1.accountType='INVESTOR'

UNION ALL

SELECT 'productOid, investorOid,totalVolume,holdVolume,toConfirmInvestVolume,toConfirmRedeemVolume,redeemableHoldVolume,lockRedeemHoldVolume,expGoldVolume,totalInvestVolume,accruableHoldVolume,value,holdTotalIncome, totalBaseIncome,totalRewardIncome,holdYesterdayIncome,yesterdayBaseIncome,yesterdayRewardIncome,incomeAmount,redeemableIncome,lockIncome,confirmDate,expectIncome,expectIncomeExt,accountType,maxHoldVolume,dayRedeemVolume,dayInvestVolume,dayRedeemCount, productAlias, holdStatus, productType'
UNION ALL
SELECT 
  CONCAT( t1.productOid, ', ',
  IFNULL(t1.investorOid,''), ', ',
  TRUNCATE(t1.totalVolume * 100, 0), ', ',
  TRUNCATE(t1.holdVolume * 100, 0), ', ',
  TRUNCATE(t1.toConfirmInvestVolume * 100, 0), ', ',
  TRUNCATE(t1.toConfirmRedeemVolume * 100, 0), ', ',
  TRUNCATE(t1.redeemableHoldVolume * 100, 0), ', ',
  TRUNCATE(t1.lockRedeemHoldVolume * 100, 0), ', ',
  TRUNCATE(t1.expGoldVolume * 100, 0), ', ',
  TRUNCATE(t1.totalInvestVolume * 100, 0), ', ',
  TRUNCATE(t1.accruableHoldVolume * 100, 0), ', ',
  TRUNCATE(t1.value * 100, 0), ', ',
  TRUNCATE(t1.holdTotalIncome * 100, 0), ', ',
  TRUNCATE(t1.totalBaseIncome * 100, 0), ', ',
  TRUNCATE(t1.totalRewardIncome * 100, 0), ', ',
  TRUNCATE(t1.holdYesterdayIncome * 100, 0), ', ',
  TRUNCATE(t1.yesterdayBaseIncome * 100, 0), ', ',
  TRUNCATE(t1.yesterdayRewardIncome * 100, 0), ', ',
  TRUNCATE(t1.incomeAmount * 100, 0), ', ',
  TRUNCATE(t1.redeemableIncome * 100, 0), ', ',
  TRUNCATE(t1.lockIncome * 100, 0), ', ',
  IFNULL(t1.confirmDate,''), ', ',
  TRUNCATE(t1.expectIncome * 100, 0), ', ',
  TRUNCATE(t1.expectIncomeExt * 100, 0), ', ',
  t1.accountType, ', ',
  TRUNCATE(t1.maxHoldVolume * 100, 0), ', ',
  TRUNCATE(t1.dayRedeemVolume * 100, 0), ', ',
  TRUNCATE(t1.dayInvestVolume * 100, 0), ', ',
  t1.dayRedeemCount, ', ',
  IFNULL(t1.productAlias,''), ', ',
  t1.holdStatus, ', ',
  t2.type)
FROM
  `t_money_publisher_hold` t1,`t_gam_product` t2  WHERE t1.productOid=t2.oid AND t1.updateTime >= '#holdStartTime' AND t1.updateTime <= '#holdEndTime' AND t1.accountType='INVESTOR' limit #startIndex,#rows
