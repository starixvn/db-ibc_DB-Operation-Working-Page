
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OddsCompiler_UpdateOdds] @UserId INT
	,@Id INT
	,@OWPMatchId INT
	,@Bettype INT
	,@SessionId NVARCHAR(50) = NULL
	,@Choice TINYINT
	,@Odds MONEY = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*          
 Created: 20181030@Leo: negative Handicap
 Task : negative HDP
 DB: bodb_OWP          
          
 Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]      
	20181016@Kane.Le: Insert message for assignee traders - [Redmine: #102867]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @TeamChoice TINYINT
		,@OldHandicap DECIMAL (4)
		,@OldOddsText NVARCHAR(50) = NULL
		,@NewOddsText NVARCHAR(50) = NULL
		,@HomeOrAwayString NVARCHAR(50) = ''
		,@HandicapTextString NVARCHAR(50) = NULL		 
		,@BettypeName NVARCHAR(50) = ''
		,@MessageTemplate NVARCHAR(MAX) = ''
		,@MessageType INT
		,@Assignee TVP_INT

	SELECT @OldOddsText = COALESCE(@OldOddsText + '/', '') +  CAST(ISNULL(Odds, 0) AS VARCHAR)
	FROM MatchRecommendOddsDetail
	WHERE MatchRecommendOddsId = @Id

	UPDATE dbo.MatchRecommendOddsDetail WITH (ROWLOCK, UPDLOCK)
	SET Odds = @Odds
	WHERE MatchRecommendOddsId = @Id
		AND Choice = @Choice

	-- insert message  	
	IF (dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1)
	BEGIN
		SELECT @NewOddsText = COALESCE(@NewOddsText + '/', '') + CAST(ISNULL(Odds, 0) AS VARCHAR)
		FROM MatchRecommendOddsDetail
		WHERE MatchRecommendOddsId = @Id

		IF @Bettype = 1 OR @Bettype = 7
		BEGIN
			SELECT @OldHandicap = m.HDP
			FROM MatchRecommendOdds m
			WHERE m.MatchRecommendOddsId = @Id
		END
		SELECT @BettypeName = ShortName
		FROM dbo.MajorBettype WITH (NOLOCK)
		WHERE BettypeId = @Bettype

		SELECT @MessageTemplate = mt.MsgTemplateContent
			,@MessageType = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'MatchRecommendOddsUpdate'

		IF @OldHandicap IS NULL OR @OldHandicap = 0
		SET @HandicapTextString = ''
		ELSE 
		SET @HandicapTextString = @OldHandicap
		 		
		SELECT @TeamChoice = TeamChoice
		FROM MatchRecommendOdds WITH (NOLOCK) 
		WHERE OWPMatchId = @OWPMatchId AND Bettype = @Bettype

		IF @TeamChoice = 1 
		SET @HomeOrAwayString = 'Home@'
		ELSE IF @TeamChoice = 2 
		SET @HomeOrAwayString = 'Away@'

		SET @OldOddsText = @HomeOrAwayString + ISNULL(@HandicapTextString, '')  +  ' ' + @OldOddsText
		SET @NewOddsText =  @HomeOrAwayString+ ISNULL(@HandicapTextString, '') + ' ' + @NewOddsText

		SET @MessageTemplate = REPLACE(@MessageTemplate, '<bettype>', ISNULL(@BettypeName, ''))
		SET @MessageTemplate = REPLACE(@MessageTemplate, '<oldodds>', ISNULL(@OldOddsText, ''))
		SET @MessageTemplate = REPLACE(@MessageTemplate, '<newodds>',  ISNULL(@NewOddsText, ''))
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