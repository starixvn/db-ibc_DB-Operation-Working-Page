
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_InsertRecommendOdds] @UserId INT
	,@OWPMatchId INT
	,@SessionId NVARCHAR(50) = NULL
	,@Bettype INT
	,@Handicap SMALLMONEY
	,@RecommendOdds NVARCHAR(MAX)
	,@TeamChoice INT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
	,@Id INT OUTPUT
AS
/*
Created: 20161205@Tim.Trinh
Task : insert recommend odds
DB: bodb_OWP

Revisions:
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]  
	20181016@Kane.Le: Insert message for assignee traders - [Redmine: #102867]
*/
BEGIN
	SET NOCOUNT ON

	IF EXISTS (
			SELECT 1
			FROM dbo.MatchRecommendOdds WITH (NOLOCK)
			WHERE OWPMatchId = @OWPMatchId
				AND Bettype = @Bettype
				AND TeamChoice = @TeamChoice
				AND (
					(
						HDP IS NULL
						AND @Handicap IS NULL
						)
					OR HDP = @Handicap
					)
			)
	BEGIN
		SELECT @ErrMsg = 'The recommend odds is already existed. Please add another one'
			,@ErrCode = 7201 -- ActionId + 01

		RETURN
	END

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@Xml XML
		,@idoc INT
		,@BettypeName NVARCHAR(50) = ''
		,@NewOddsText  NVARCHAR(50) = ''
		,@HomeOrAwayString NVARCHAR(50) = ''
		,@HandicapTextString NVARCHAR(50) = NULL		
		,@OddsText NVARCHAR(50) = ''
		,@MessageTemplate NVARCHAR(MAX) = ''
		,@MessageType INT
		,@Assignee TVP_INT

	IF EXISTS (
			SELECT 1
			FROM dbo.MatchRecommendOdds WITH (NOLOCK)
			WHERE OWPMatchId = @OWPMatchId
				AND Bettype = @Bettype
				AND HDP = @Handicap
			)
	BEGIN
		SELECT @ErrMsg = 'Duplicate recommend odds'
			,@ErrCode = 4402 -- ActionId + 02

		RETURN
	END

	IF OBJECT_ID('tempdb..#RecommendOdds') IS NOT NULL
	BEGIN
		DROP TABLE #RecommendOdds
	END

	CREATE TABLE #RecommendOdds (
		Choice INT
		,Odds MONEY
		)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@RecommendOdds

	INSERT INTO #RecommendOdds (
		Choice
		,Odds
		)
	SELECT DISTINCT data.Choice
		,data.Odds
	FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Choice VARCHAR(20), Odds MONEY) AS data

	EXEC sp_xml_removedocument @idoc

	SET @StartRun = GETDATE()

	BEGIN TRY
		INSERT INTO dbo.MatchRecommendOdds (
			OWPMatchId
			,Bettype
			,HDP
			,TeamChoice
			,CreatedBy
			,CreatedDate
			)
		VALUES (
			@OWPMatchId
			,@Bettype
			,@Handicap
			,@TeamChoice
			,@UserId
			,GETDATE()
			)

		SELECT @Id = @@IDENTITY

		INSERT INTO dbo.MatchRecommendOddsDetail (
			MatchRecommendOddsId
			,Choice
			,Odds
			)
		SELECT DISTINCT @Id
			,Choice
			,Odds
		FROM #RecommendOdds

		-- insert message  	
		-- IF (dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1)
		BEGIN
			SELECT @OddsText = COALESCE(@OddsText + '/', '') + CAST(ISNULL(Odds, 0) AS VARCHAR)
			FROM #RecommendOdds

			SET @OddsText = SUBSTRING(@OddsText, 2, LEN(@OddsText))
			
			SELECT @BettypeName = ShortName
			FROM dbo.MajorBettype WITH (NOLOCK)
			WHERE BettypeId = @Bettype

			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageType = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'MatchRecommendOddsInsert'

		 
		

		IF @Bettype = 1 OR @Bettype = 7					
			BEGIN
				IF @TeamChoice = 1 
				SET @HomeOrAwayString = 'Home@'
				ELSE IF @TeamChoice = 2 
				SET @HomeOrAwayString = 'Away@'
			END
		ELSE
		BEGIN
			SET @Handicap = NULL
			SET @HomeOrAwayString = ''
		END

		IF @Handicap IS NULL OR @Handicap = 0
		SET @HandicapTextString = ''
		ELSE 
		SET @HandicapTextString = @Handicap
		 
		SET @NewOddsText =  @HomeOrAwayString+ ISNULL(@HandicapTextString, '') + ' ' + @OddsText

			SET @MessageTemplate = REPLACE(@MessageTemplate, '<bettype>', ISNULL(@BettypeName, ''))
			SET @MessageTemplate = REPLACE(@MessageTemplate, '<oldodds>', '')
			SET @MessageTemplate = REPLACE(@MessageTemplate, '<newodds>', ISNULL(@NewOddsText, ''))
			SET @MessageTemplate = dbo.[fnc_ReplaceMessageTemplate](@MessageTemplate, @OWPMatchId, @UserId)

			INSERT INTO @Assignee
			SELECT UserId
			FROM dbo.[fnc_GetAssigneeToSendMessage](@OWPMatchId, 4)

			EXEC dbo.OWP_MessageInsert @UserId = @UserId
				,@MessageContent = @MessageTemplate
				,@MessageTo = @Assignee
				,@IsImportant = 0
				,@MessageType = @MessageType
				,@SessionId = @SessionId
				,@ErrCode = @ErrCode OUTPUT
				,@ErrMsg = @ErrMsg OUTPUT
		END

		SELECT @ErrMsg = @Id
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Insert recommend odds failed. Please try again.'
			,@ErrCode = 4401 -- ActionId + 01

		RETURN
	END CATCH

	DROP TABLE #RecommendOdds
END