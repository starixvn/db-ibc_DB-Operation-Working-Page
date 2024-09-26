/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_SpecialProduct_Get]
AS	
/*
Created: 20180617@Carlos.Nguyen
Task : Get all Special Product
DB: bodb_OWP

Revisions:
	20180617@Carlos.Nguyen: Init sp - [Redmine: #134338]
	20210831@Johnny.Thai: Remove CN88 - [Feature: #160666]
*/

BEGIN
	SET NOCOUNT ON
	
	SELECT sp.ProductId
	,sp.Maxbet_FTHDP 
	,sp.Maxbet_NoOfCorner 
	,sp.Spread_NoOfCorner 
	,sp.Maxbet_NextCorner 
	,sp.Spread_NextCorner 
	,sp.Maxbet_10_15Mins 
	,sp.Spread_10_15Mins 
	,sp.Maxbet_TB 
	,sp.Spread_TB 
	,sp.Maxbet_NextTB 
	,sp.Spread_NextTB 
	,sp.Maxbet_PS 
	,sp.Spread_PS 
	,sp.Maxbet_Winner 
	,sp.Spread_Winner 
	,sp.Remark
	,sp.LastUpdate
	,sp.[Type]
	FROM SpecialProduct AS sp WITH (NOLOCK)
	WHERE sp.[Type] = 'MBC'
END