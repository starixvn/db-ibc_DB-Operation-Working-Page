
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_UpdateRecommendOdds] @Id INT
	,@UserId INT
	,@SessionId NVARCHAR(50) = NULL
	,@OWPMatchId INT
	,@Bettype INT
	,@OldHandicap DECIMAL
	,@Handicap DECIMAL
	,@RecommendOdds NVARCHAR(MAX)
	,@TeamChoice INT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20161205@Tim.Trinh
Task : update recommend odds
DB: bodb_OWP

Revisions:
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20181016@Kane.Le: Insert message for assignee traders - [Redmine: #102867]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@Xml XML
		,@idoc INT
		,@CreatedBy INT
		,@CreatedDate DATETIME
		,@HomeOrAwayString NVARCHAR(50) = ''
		,@OldHandicapTextString NVARCHAR(50) = ''
		,@HandicapTextString NVARCHAR(50) = ''
		,@BettypeName NVARCHAR(50) = ''
		,@OldOddsText NVARCHAR(50) = ''
		,@NewOddsText NVARCHAR(50) = ''
		,@OddsText NVARCHAR(50) = ''
		,@MessageTemplate NVARCHAR(MAX) = ''
		,@MessageType INT
		,@Assignee TVP_INT

	IF OBJECT_ID('tempdb..#RecommendOdds') IS NOT NULL
	BEGIN
		DROP TABLE #RecommendOdds
	END

	CREATE TABLE #RecommendOdds (
		MatchRecommendOddsId INT
		,Choice INT
		,Odds MONEY
		)

	IF EXISTS (
			SELECT 1
			FROM dbo.MatchRecommendOdds WITH (NOLOCK)
			WHERE OWPMatchId = @OWPMatchId
				AND Bettype = @Bettype
				AND HDP = @Handicap
				AND HDP <> @OldHandicap
			)
	BEGIN
		SELECT @ErrMsg = 'Duplicate recommend odds'
			,@ErrCode = 4502 -- ActionId + 02

		RETURN
	END

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@RecommendOdds

	INSERT INTO #RecommendOdds (
		Choice
		,Odds
		)
	SELECT DISTINCT data.Choice
		,data.Odds
	FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Choice INT, Odds MONEY) AS data

	EXEC sp_xml_removedocument @idoc

	SELECT @OldOddsText = COALESCE(@OldOddsText + '/', '') + CAST(ISNULL(Odds, 0) AS VARCHAR)
	FROM MatchRecommendOddsDetail
	WHERE MatchRecommendOddsId = @Id

	 	BEGIN TRY
	UPDATE dbo.MatchRecommendOdds
	SET HDP = @Handicap
		,TeamChoice = @TeamChoice
	WHERE MatchRecommendOddsId = @Id

	DELETE
	FROM MatchRecommendOddsDetail
	WHERE MatchRecommendOddsId = @Id
		AND Choice IN (
			SELECT Choice
			FROM #RecommendOdds
			)

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
	IF (dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1)
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
		WHERE mt.MsgTemplateCode = 'MatchRecommendOddsUpdate'

		IF @Bettype = 1
			OR @Bettype = 7
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

		IF @Handicap IS NULL
			OR @Handicap = 0
			SET @HandicapTextString = ''
		ELSE
			SET @HandicapTextString = @Handicap

		IF @OldHandicap IS NULL
			OR @OldHandicap = 0
			SET @OldHandicapTextString = ''
		ELSE
			SET @OldHandicapTextString = @OldHandicap

		SET @OldOddsText = @HomeOrAwayString + ISNULL(@OldHandicapTextString, '') + ' ' + @OldOddsText
		SET @NewOddsText = @HomeOrAwayString + ISNULL(@HandicapTextString, '') + ' ' + ISNULL(@OddsText, '')
		SET @MessageTemplate = REPLACE(@MessageTemplate, '<bettype>', ISNULL(@BettypeName, ''))
		SET @MessageTemplate = REPLACE(@MessageTemplate, '<oldodds>', ISNULL(@OldOddsText, ''))
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

	 END TRY
	 
	BEGIN CATCH
		SELECT @ErrMsg = 'Update recommend odds failed. Please try again.'
			,@ErrCode = 4501 -- ActionId + 01

		RETURN
	END CATCH
	 
	DROP TABLE #RecommendOdds
END