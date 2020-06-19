/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_SpecialProduct_Delete]
	@ActorId INT
	,@ProductId INT
AS
/*
Created: 20180617@Carlos.Nguyen
Task : delete Special Product
DB: bodb_OWP

Revisions:
	20180617@Carlos.Nguyen: Init sp - [Redmine: #134338]
*/

BEGIN
	SET NOCOUNT ON
	BEGIN -- WRITE LOG
	
	-- Declare variable old data
	DECLARE @Maxbet_FTHDPOld MONEY
			,@Maxbet_NoOfCornerOld MONEY
			,@Spread_NoOfCornerOld MONEY
			,@Maxbet_NextCornerOld MONEY
			,@Spread_NextCornerOld MONEY
			,@Maxbet_10_15MinsOld MONEY 
			,@Spread_10_15MinsOld MONEY 
			,@Maxbet_TBOld MONEY 
			,@Spread_TBOld MONEY 
			,@Maxbet_NextTBOld MONEY
			,@Spread_NextTBOld MONEY 
			,@Maxbet_PSOld MONEY 
			,@Spread_PSOld MONEY 
			,@Maxbet_WinnerOld MONEY
			,@Spread_WinnerOld MONEY 
			,@RemarkOld NVARCHAR(2000)
			,@ProductSetting VARCHAR(255)
			,@Action INT
			,@OldValue MONEY
			,@NewValue MONEY
			,@ModifyDate DATETIME
			,@ModifyBy INT
			
	SELECT @Maxbet_FTHDPOld=sp.Maxbet_FTHDP
			,@Maxbet_NoOfCornerOld=sp.Maxbet_NoOfCorner
			,@Spread_NoOfCornerOld=sp.Spread_NoOfCorner
			,@Maxbet_NextCornerOld=sp.Maxbet_NextCorner
			,@Spread_NextCornerOld=sp.Spread_NextCorner
			,@Maxbet_10_15MinsOld=sp.Maxbet_10_15Mins
			,@Spread_10_15MinsOld=sp.Spread_10_15Mins
			,@Maxbet_TBOld=sp.Maxbet_TB
			,@Spread_TBOld=sp.Spread_TB
			,@Maxbet_NextTBOld=sp.Maxbet_NextTB
			,@Spread_NextTBOld=sp.Spread_NextTB
			,@Maxbet_PSOld=sp.Maxbet_PS
			,@Spread_PSOld=sp.Spread_PS
			,@Maxbet_WinnerOld=sp.Maxbet_Winner
			,@Spread_WinnerOld=sp.Spread_Winner
			,@RemarkOld=sp.Remark
	FROM SpecialProduct AS sp WITH (NOLOCK)
	WHERE sp.ProductId=@ProductId
	
	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@Xml XML

	SET @StartRun = GETDATE()
	-- Old data
	SET @Xml = (
			SELECT @ProductId AS '@pid'
				,ISNULL(@Maxbet_FTHDPOld,'') AS '@fthdp'
				,ISNULL(@Maxbet_NoOfCornerOld,'') AS '@mbnoofcorner'
				,ISNULL(@Spread_NoOfCornerOld,'') AS '@spreadnoofcorner'
				,ISNULL(@Maxbet_NextCornerOld,'') AS '@mbnextcorner'
				,ISNULL(@Spread_NextCornerOld,'') AS '@spreadnextcorner'
				,ISNULL(@Maxbet_10_15MinsOld,'') AS '@mb1015mins'
				,ISNULL(@Spread_10_15MinsOld,'') AS '@sp1015mins'
				,ISNULL(@Maxbet_TBOld,'') AS '@mbtb'
				,ISNULL(@Spread_TBOld,'') AS '@spreadtb'
				,ISNULL(@Maxbet_NextTBOld,'') AS '@mbntb'
				,ISNULL(@Spread_NextTBOld,'') AS '@spreadntb'
				,ISNULL(@Maxbet_PSOld,'') AS '@mbps'
				,ISNULL(@Spread_PSOld,'') AS '@spreadps'
				,ISNULL(@Maxbet_WinnerOld,'') AS '@mbwinner'
				,ISNULL(@Spread_WinnerOld,'') AS '@spreadwinner'
				,ISNULL(@RemarkOld,'') AS '@remark'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	
	--New data
	SET @LogData = NULL
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)
	IF @ProductId<>-1
		EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
			,@SPName = 'OWP_SpecialProductDeleteRow'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @ProductId
			,@Data = @LogData
			,@DataOld = @LogDataOld
	END -- END WRITE LOG
	
	DELETE FROM SpecialProduct
	WHERE ProductId=@ProductId
END