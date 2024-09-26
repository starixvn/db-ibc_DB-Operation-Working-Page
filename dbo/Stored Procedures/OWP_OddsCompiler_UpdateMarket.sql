
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OddsCompiler_UpdateMarket] @ActorId INT
	,@SessionId VARCHAR(50)
	,@OWPMatchId INT
	,@Market NVARCHAR(250)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(MAX) = '' OUTPUT
AS
/*          
 Created: 20191112@Leo
 Task : update market
 DB: bodb_OWP          
          
 Revisions:
	20191112@Leo: Initial SP - [Redmine: #123167]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME = GETDATE()
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@LogDataOld NVARCHAR(MAX)
		,@Xml XML
	DECLARE @OldMarket NVARCHAR(250)

	SELECT @OldMarket = Market
	FROM dbo.MatchInfo WITH (NOLOCK)
	WHERE OWPMatchId = @OWPMatchId

	IF ISNULL(@OldMarket, '') = ISNULL(@Market, '')
	BEGIN
		SELECT @ErrCode = 1
			,@ErrMsg = 'No change'

		RETURN
	END

	SET @Xml = (
			SELECT @OldMarket AS '@mk'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

	UPDATE dbo.MatchInfo WITH (ROWLOCK)
	SET Market = @Market
	WHERE OWPMatchId = @OWPMatchId

	SET @Xml = (
			SELECT @Market AS '@mk'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
		,@SPName = 'OWP_OddsCompiler_UpdateMarket'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @OWPMatchId
		,@Data = @LogData
		,@DataOld = @LogDataOld

	SET @Xml = (
			SELECT @OldMarket AS '@old'
				,@Market AS '@new'
			FOR XML PATH('z')
			)

	SELECT @ErrMsg = CAST(@Xml AS NVARCHAR(MAX))
END