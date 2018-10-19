
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OddsCompiler_Delete] @MatchRecommendOddsIds NVARCHAR(MAX)
	,@UserId INT
	,@SessionId VARCHAR(50) = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*          
 Created: 20170317@Alvin.Nguyen
 Task : delete odds compiler
 DB: bodb_OWP          
          
 Revisions:      
	20181004@Kane.Le: delete odds compiler - [Redmine: #92868]
	20181016@Kane.Le: Insert message for assignee traders - [Redmine: #102867]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Iterator INT
		,@TeamChoice TINYINT
		,@TotalOWPMatch INT
		,@OWPMatchId INT
		,@MatchRecommendOddsDetail INT
		,@OldHandicap DECIMAL(4)
		,@BetTypeId INT
		,@BettypeName NVARCHAR(50) = ''
		,@HomeOrAwayString NVARCHAR(50) = ''
		,@HandicapTextString NVARCHAR(50) = NULL
		,@MessageTemplate NVARCHAR(MAX) = ''
		,@OldOddsText NVARCHAR(50) = ''
		,@MessageType INT
		,@Assignee TVP_INT

	CREATE TABLE #MatchRecommendOddsIds (
		Idx SMALLINT PRIMARY KEY IDENTITY
		,Id INT
		)

	INSERT INTO #MatchRecommendOddsIds
	SELECT val
	FROM dbo.strSplit(@MatchRecommendOddsIds, ',')

	-----
	IF (dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1)
	BEGIN
		SELECT @TotalOWPMatch = COUNT(m.Id)
		FROM #MatchRecommendOddsIds m

		IF @TotalOWPMatch > 0
			SELECT @OWPMatchId = m.OWPMatchId
			FROM MatchRecommendOdds m
			WHERE m.MatchRecommendOddsId IN (
					SELECT Id
					FROM #MatchRecommendOddsIds
					)

		SET @Iterator = 1

		WHILE (
				@Iterator <= (
					SELECT MAX(Idx)
					FROM #MatchRecommendOddsIds
					)
				)
		BEGIN
			SELECT @MatchRecommendOddsDetail = Id
			FROM #MatchRecommendOddsIds
			WHERE Idx = @Iterator

			SELECT @BetTypeId = m.Bettype
			FROM MatchRecommendOdds m WITH (NOLOCK)
			WHERE MatchRecommendOddsId = @MatchRecommendOddsDetail

			SELECT @TeamChoice = m.TeamChoice
			FROM MatchRecommendOdds m WITH (NOLOCK)
			WHERE m.MatchRecommendOddsId = @MatchRecommendOddsDetail
				AND m.Bettype = @BetTypeId

			IF @TeamChoice = 1
				SET @HomeOrAwayString = 'Home@'
			ELSE IF @TeamChoice = 2
				SET @HomeOrAwayString = 'Away@'

			SELECT @BettypeName = ShortName
			FROM dbo.MajorBettype WITH (NOLOCK)
			WHERE BettypeId = @BetTypeId

			IF @BetTypeId = 1
				OR @BetTypeId = 7
			BEGIN
				SELECT @OldHandicap = m.HDP
				FROM MatchRecommendOdds m
				WHERE m.MatchRecommendOddsId = @MatchRecommendOddsDetail
			END

			IF @OldHandicap IS NULL
				OR @OldHandicap = 0
				SET @HandicapTextString = ''
			ELSE
				SET @HandicapTextString = @OldHandicap

			--SET @OldOddsText = ''
			SELECT @OldOddsText = COALESCE(@OldOddsText + '/', '') + CAST(ISNULL(Odds, 0) AS VARCHAR)
			FROM MatchRecommendOddsDetail
			WHERE MatchRecommendOddsId = @MatchRecommendOddsDetail

			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageType = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'MatchRecommendOddsUpdate'

			SET @OldOddsText = @HomeOrAwayString + ISNULL(@HandicapTextString, '') + ' ' + @OldOddsText
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
				,@ErrCode = @ErrCode OUTPUT
				,@ErrMsg = @ErrMsg OUTPUT

			SET @Iterator = @Iterator + 1
		END
	END

	DELETE
	FROM dbo.MatchRecommendOddsDetail
	WHERE MatchRecommendOddsId IN (
			SELECT Id
			FROM #MatchRecommendOddsIds
			)

	DELETE
	FROM dbo.MatchRecommendOdds
	WHERE MatchRecommendOddsId IN (
			SELECT Id
			FROM #MatchRecommendOddsIds
			)

	DROP TABLE #MatchRecommendOddsIds
END