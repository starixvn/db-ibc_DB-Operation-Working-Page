
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_DeleteRecommendOdds] @Id INT
	,@UserId INT
	,@SessionId NVARCHAR(50) = NULL
	,@OWPMatchId INT
	,@Bettype INT
	,@OldHandicap SMALLMONEY
AS
/*
Created: 20161206@Tim.Trinh
Task : delete recommend odds
DB: bodb_OWP

Revisions:
	20181004@Kane.Le: delete recommend odds
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20181016@Kane.Le: Insert message for assignee traders - [Redmine: #102867]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE  @TeamChoice TINYINT,
	@BettypeName NVARCHAR(50) = ''
	,@HomeOrAwayString NVARCHAR(50) = ''		 
		,@HandicapTextString NVARCHAR(50) = ''
		,@OldOddsText NVARCHAR(50) = ''
		,@MessageTemplate NVARCHAR(MAX) = ''
		,@MessageType INT
		,@Assignee TVP_INT

	SELECT @OldOddsText = COALESCE(@OldOddsText + '/', '') + CAST(ISNULL(Odds, 0) AS VARCHAR)
	FROM MatchRecommendOddsDetail
	WHERE MatchRecommendOddsId = @Id	

	IF @Bettype = 1
			OR @Bettype = 7
		BEGIN
			 		
		SELECT @TeamChoice = TeamChoice
		FROM MatchRecommendOdds WITH (NOLOCK) 
		WHERE OWPMatchId = @OWPMatchId AND Bettype = @Bettype
			IF @TeamChoice = 1
				SET @HomeOrAwayString = 'Home@'
			ELSE IF @TeamChoice = 2
				SET @HomeOrAwayString = 'Away@'
		END
		ELSE
		BEGIN
			SET @OldHandicap = NULL
			SET @HomeOrAwayString = ''
		END

		IF @OldHandicap IS NULL
			OR @OldHandicap = 0
			SET @HandicapTextString = ''
		ELSE
			SET @HandicapTextString = @OldHandicap


	SELECT @OWPMatchId = OWPMatchId
	FROM dbo.MatchRecommendOdds WITH (NOLOCK)
	WHERE MatchRecommendOddsId = @Id

	DELETE
	FROM dbo.MatchRecommendOddsDetail WITH (ROWLOCK, UPDLOCK)
	WHERE MatchRecommendOddsId = @Id

	DELETE
	FROM dbo.MatchRecommendOdds WITH (ROWLOCK, UPDLOCK)
	WHERE MatchRecommendOddsId = @Id

	IF (dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1)
	BEGIN	 

		SELECT @BettypeName = ShortName
		FROM dbo.MajorBettype WITH (NOLOCK)
		WHERE BettypeId = @Bettype

		SELECT @MessageTemplate = mt.MsgTemplateContent
			,@MessageType = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'MatchRecommendOddsUpdate'

		SET @OldOddsText = @HomeOrAwayString + ISNULL(@HandicapTextString, '')  +  ' ' + @OldOddsText


		SET @MessageTemplate = REPLACE(@MessageTemplate, '<bettype>', ISNULL(@BettypeName, ''))
		SET @MessageTemplate = REPLACE(@MessageTemplate, '<oldodds>', ISNULL(@OldOddsText, ''))
		SET @MessageTemplate = REPLACE(@MessageTemplate, '<newodds>', '')
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
			,@ErrCode = 0
			,@ErrMsg = ''
	END
END