
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OddsCompiler_Insert] @UserId INT
	,@OWPMatchId INT
	,@Bettype INT
	,@SessionId VARCHAR(50) = NULL
	,@TeamChoice TINYINT = 0
	,@HDP SMALLMONEY = NULL
	,@Choice TINYINT = NULL
	,@Odds MONEY = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*          
 Created: 20170320@Alvin.Nguyen
 Task : insert odds compiler
 DB: bodb_OWP          
          
 Revisions:      
     20181030@Leo: negative Handicap - [Redmine: #92868]
     20181016@Kane.Le: Insert message for assignee traders - [Redmine: #102867]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Detail TABLE (Choice TINYINT)
	DECLARE @1X2 TINYINT = 5
	DECLARE @BettypeName NVARCHAR(50) = ''
		,@HomeOrAwayString NVARCHAR(50) = ''
		,@HandicapTextString NVARCHAR(50) = NULL
		,@NewOddsText NVARCHAR(50) = ''
		,@MessageTemplate NVARCHAR(MAX) = ''
		,@MessageType INT
		,@Assignee TVP_INT

	IF EXISTS (
			SELECT 1
			FROM dbo.MatchRecommendOdds WITH (NOLOCK)
			WHERE OWPMatchId = @OWPMatchId
				AND Bettype = @Bettype
				AND TeamChoice = @TeamChoice
				AND (
					(
						HDP IS NULL
						AND @HDP IS NULL
						)
					OR HDP = @HDP
					)
			)
	BEGIN
		SELECT @ErrMsg = 'The recommend odds is already existed. Please add another one'
			,@ErrCode = 7201 -- ActionId + 01

		RETURN
	END

	INSERT INTO dbo.MatchRecommendOdds (
		OWPMatchId
		,Bettype
		,TeamChoice
		,HDP
		,CreatedBy
		)
	VALUES (
		@OWPMatchId
		,@Bettype
		,@TeamChoice
		,@HDP
		,@UserId
		)

	DECLARE @Id INT = @@IDENTITY

	INSERT INTO @Detail
	VALUES (1)
		,(2)

	IF @Bettype = @1X2
		INSERT @Detail
		VALUES (3)

	INSERT INTO dbo.MatchRecommendOddsDetail (
		MatchRecommendOddsId
		,Choice
		)
	SELECT @Id
		,Choice
	FROM @Detail

	IF @Choice > 0
	BEGIN
		UPDATE dbo.MatchRecommendOddsDetail WITH (ROWLOCK, UPDLOCK)
		SET Odds = @Odds
		WHERE MatchRecommendOddsId = @Id
			AND Choice = @Choice
	END

	SET @ErrMsg = @Id

	-- insert message  	
	IF (dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1)
	BEGIN
		SELECT @BettypeName = ShortName
		FROM dbo.MajorBettype WITH (NOLOCK)
		WHERE BettypeId = @Bettype

		SELECT @MessageTemplate = mt.MsgTemplateContent
			,@MessageType = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'MatchRecommendOddsInsert'

		SELECT @NewOddsText = COALESCE(@NewOddsText + '/', '') + CAST(ISNULL(Odds, 0) AS VARCHAR)
		FROM MatchRecommendOddsDetail
		WHERE MatchRecommendOddsId = @Id

		IF @NewOddsText IS NULL
		BEGIN
			SET @NewOddsText = ''
		END

		IF @Bettype <> 1
			OR @Bettype <> 7
		BEGIN
			SET @HDP = NULL
		END

		IF @TeamChoice = 1
			SET @HomeOrAwayString = 'Home@'
		ELSE IF @TeamChoice = 2
			SET @HomeOrAwayString = 'Away@'

		IF @HDP IS NULL
			OR @HDP = 0
			SET @HandicapTextString = ''
		ELSE
			SET @HandicapTextString = @HDP

		SET @NewOddsText = @HomeOrAwayString + ISNULL(@HandicapTextString, '') + ' ' + @NewOddsText
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
END