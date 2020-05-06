
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LeagueManagement_UpdateTVCondition] @ActorId INT
	,@UpdateTvListXml NVARCHAR(MAX)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(MAX) = '' OUTPUT
AS
/*
Created: 20200408@Tyler.Dang
Task : Update TVlist
DB: bodb_OWP
  
Revisions:
	20200408@Tyler.Dang: Init [Redmine: #131923]
	
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@Xml XML
		,@OWPLeagueId INT

		-- Log  
		SET @StartRun = GETDATE()
		SET @Xml = (
				SELECT [OperatorType] AS '@ot'
					,[Value] AS '@vl'
				FROM dbo.[LeagueSettingTVCondition] WITH (NOLOCK)
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

	DELETE FROM LeagueSettingTVCondition
	DECLARE @idoc INT
	EXEC sp_xml_preparedocument @idoc OUTPUT
			,@UpdateTvListXml

	INSERT INTO LeagueSettingTVCondition (
			OperatorType,
			Value
		)
	SELECT [Label]
		,[Value]
	FROM OPENXML(@idoc, '/Root/TVList', 1) WITH ([Label] nvarchar(50), [Value] nvarchar(50))

	EXEC sp_xml_removedocument @idoc

	-- For write log  
		SET @Xml = (
				SELECT [OperatorType] AS '@ot'
					,[Value] AS '@vl'
				FROM dbo.[LeagueSettingTVCondition] WITH (NOLOCK)
				FOR XML PATH('z')
					,ROOT('r')
				)

		SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		IF ISNULL(@LogData, '') <> ''
			OR ISNULL(@LogDataOld, '') <> ''
		BEGIN
			EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
				,@SPName = 'OWP_LeagueManagement_UpdateTVCondition'
				,@LoggedDate = @StartRun
				,@Duration = @Duration
				,@ObjectId = NULL
				,@Data = @LogData
				,@DataOld = @LogDataOld
		END

	SELECT @ErrCode = 0
		,@ErrMsg = 'TV list has been edited successfully!'
END