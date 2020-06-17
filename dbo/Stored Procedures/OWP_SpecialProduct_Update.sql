/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_SpecialProduct_Update]
	@ProductId INT
	,@Maxbet_FTHDP MONEY
	,@Maxbet_NoOfCorner MONEY
	,@Spread_NoOfCorner MONEY
	,@Maxbet_NextCorner MONEY
	,@Maxbet_10_15Mins MONEY
	,@Spread_10_15Mins MONEY
	,@Maxbet_NoOfTB MONEY
	,@Spread_NoOfTB MONEY
	,@Maxbet_NextTB MONEY
	,@Spread_NextTB MONEY
	,@Maxbet_PS MONEY
	,@Spread_PS MONEY
	,@Maxbet_Winner MONEY
	,@Spread_Winner MONEY
	,@Remark NVARCHAR(2000)
	,@LastUpdate VARCHAR(255)
	,@Type VARCHAR(10)
AS
/*
Created: 20180617@Carlos.Nguyen
Task : update Special Product
DB: bodb_OWP

Revisions:
	20180617@Carlos.Nguyen: Init sp - [Redmine: #134338]
*/

BEGIN
	SET NOCOUNT ON
	
	DELETE FROM SpecialProduct
	WHERE ProductId=@ProductId
	
	INSERT INTO SpecialProduct
	(
		Maxbet_FTHDP
		,Maxbet_NoOfCorner
		,Spread_NoOfCorner 
		,Maxbet_NextCorner 
		,Maxbet_10_15Mins 
		,Spread_10_15Mins 
		,Maxbet_TB 
		,Spread_TB 
		,Maxbet_NextTB 
		,Spread_NextTB 
		,Maxbet_PS 
		,Spread_PS 
		,Maxbet_Winner 
		,Spread_Winner 
		,Remark 
		,LastUpdate 
		,[Type]
	)
	VALUES(
		@Maxbet_FTHDP
		,@Maxbet_NoOfCorner
		,@Spread_NoOfCorner
		,@Maxbet_NextCorner
		,@Maxbet_10_15Mins
		,@Spread_10_15Mins
		,@Maxbet_NoOfTB
		,@Spread_NoOfTB 
		,@Maxbet_NextTB 
		,@Spread_NextTB
		,@Maxbet_PS 
		,@Spread_PS
		,@Maxbet_Winner 
		,@Spread_Winner 
		,@Remark 
		,@LastUpdate 
		,@Type
	)
END