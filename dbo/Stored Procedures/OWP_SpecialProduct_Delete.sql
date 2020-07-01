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
				,ISNULL(sp.Maxbet_FTHDP,'') AS '@fthdp'
				,ISNULL(sp.Maxbet_NoOfCorner,'') AS '@mbnoofcorner'
				,ISNULL(sp.Spread_NoOfCorner,'') AS '@spreadnoofcorner'
				,ISNULL(sp.Maxbet_NextCorner,'') AS '@mbnextcorner'
				,ISNULL(sp.Spread_NextCorner,'') AS '@spreadnextcorner'
				,ISNULL(sp.Maxbet_10_15Mins,'') AS '@mb1015mins'
				,ISNULL(sp.Spread_10_15Mins,'') AS '@sp1015mins'
				,ISNULL(sp.Maxbet_TB,'') AS '@mbtb'
				,ISNULL(sp.Spread_TB,'') AS '@spreadtb'
				,ISNULL(sp.Maxbet_NextTB,'') AS '@mbntb'
				,ISNULL(sp.Spread_NextTB,'') AS '@spreadntb'
				,ISNULL(sp.Maxbet_PS,'') AS '@mbps'
				,ISNULL(sp.Spread_PS,'') AS '@spreadps'
				,ISNULL(sp.Maxbet_Winner,'') AS '@mbwinner'
				,ISNULL(sp.Spread_Winner,'') AS '@spreadwinner'
				,ISNULL(sp.Remark,'') AS '@remark'
			FROM SpecialProduct AS sp WITH (NOLOCK)
			WHERE sp.ProductId=@ProductId
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	
	-- DELETE DATA
	DELETE FROM SpecialProduct
	WHERE ProductId=@ProductId
	-- END DELETE
	
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

END