SELECT 'recordAmount'
UNION ALL
SELECT COUNT(*)
FROM `t_money_investor_tradeorder` t1,`t_gam_product` t2 WHERE t1.publisherOffsetOid ='#offsetOid' AND t1.productOid=t2.oid
      AND t1.orderType in ('normalRedeem','clearRedeem','cash','cashFailed')
UNION ALL

SELECT 'investorOid,orderCode, productOid,orderType,orderTime,orderStatus,orderAmount,productType'
UNION ALL
SELECT CONCAT( t1.investorOid, ', ' ,
 t1.`orderCode`, ', ',
 t1.`productOid`, ', ',
 t1.`orderType`, ', ',
 UNIX_TIMESTAMP(t1.`orderTime`), ', ',
 t1.`orderStatus`, ', ',
 TRUNCATE(t1.`orderAmount` * 100, 0), ', ',
 t2.type)
FROM `t_money_investor_tradeorder` t1,`t_gam_product` t2 WHERE t1.publisherOffsetOid ='#offsetOid' AND t1.productOid=t2.oid
	AND t1.orderType IN ('normalRedeem','clearRedeem','cash','cashFailed') limit #orderstartIndex,#orderrows
