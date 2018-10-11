/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_InsertMatchNote] @MatchNoteId INT OUTPUT
	,@UserId INT
	,@OWPMatchId INT
	,@Note NVARCHAR(MAX)
	,@SessionId NVARCHAR(50)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20161129@Tim.Trinh
Task : Insert new MatchNote
DB: bodb_OWP

Revisions:
   20170901@Tim.Trinh: insert MatchNoteUser
   20170420@Tim.Trinh: modify time to send message
   20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @MessageTemplate NVARCHAR(MAX) = ''
		,@MessageType INT
		,@Username NVARCHAR(100)
		,@Traders NVARCHAR(MAX)
		,@StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@Xml XML
		,@EventDateTime DATETIME
		,@IsSelected BIT = 0
		,@FromTime DATETIME
		,@ToTime DATETIME
		,@FromTimeForSpecialBettype DATETIME
		,@ToTimeViewDetailForSpecialBettype DATETIME
		,@ToTimeForSpecialBettype DATETIME
	DECLARE @HomeVsAway TABLE (
		Home NVARCHAR(200)
		,Away NVARCHAR(200)
		)

	SET @StartRun = GETDATE()

	-- insert
	INSERT INTO dbo.MatchNote (
		OWPMatchId
		,CreatedBy
		,Note
		)
	VALUES (
		@OWPMatchId
		,@UserId
		,@Note
		)

	SELECT @MatchNoteId = SCOPE_IDENTITY()

	-- insert message
	SELECT @FromTime = FromTime
		,@ToTime = ToTime
		,@FromTimeForSpecialBettype = FromTimeForSpecialBettype
		,@ToTimeForSpecialBettype = ToTimeForSpecialBettype
		,@ToTimeViewDetailForSpecialBettype = ToTimeViewDetailForSpecialBettype
	FROM dbo.fnc_GetDateTimeForTraderViewTime()

	SELECT @EventDateTime = DATEADD(DAY, DATEDIFF(DAY, 0, om.EventDate), CAST(om.KickOffTime AS DATETIME))
		,@IsSelected = info.IsSelected
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
		INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON om.OWPMatchId = info.OWPMatchId
	WHERE om.OWPMatchId = @OWPMatchId

	IF (@IsSelected = 1
		AND @EventDateTime BETWEEN @FromTime
		AND @ToTimeForSpecialBettype
	)
	BEGIN
		SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageType = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'MatchNoteInsert'

		SELECT @Username = dbo.[OWP_GetUsernameByUserId](@UserId)

		INSERT INTO @HomeVsAway (
			Home
			,Away
			)
		EXEC dbo.OWP_LiveDetail_GetHomeAwayToSendMessage @OWPMatchId

		SELECT @Traders = COALESCE(@Traders + ',', '') + CAST(data.UserId AS NVARCHAR(10))
		FROM (
			SELECT DISTINCT a.UserId
			FROM dbo.Assignment AS a WITH (NOLOCK)
			WHERE a.OWPMatchId = @OWPMatchId
				AND a.Bettype > 0
			UNION
			SELECT DISTINCT a.UserId
			FROM dbo.MinorMatch AS mm WITH (NOLOCK)
				INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mm.MinorBettypeId = mb.ParentBettypeId
				INNER JOIN dbo.Assignment AS a WITH (NOLOCK) ON mm.MinorMatchId = a.OWPMatchId
				AND mb.InheritedBettypeId = a.Bettype
			WHERE mm.IsRepresented = 1
				AND mm.ParentMatchId = @OWPMatchId
			) AS data

		IF LEN(@MessageTemplate) > 0
		BEGIN
			SET @MessageTemplate = REPLACE(@MessageTemplate, '<user>', @Username)
			SET @MessageTemplate = REPLACE(@MessageTemplate, '<home>', (
						SELECT Home
						FROM @HomeVsAway
						))
			SET @MessageTemplate = REPLACE(@MessageTemplate, '<away>', (
						SELECT Away
						FROM @HomeVsAway
						))
			SET @MessageTemplate = REPLACE(@MessageTemplate, '<newnote>', @Note)
		END

		IF LEN(@Traders) > 0
			AND LEN(@MessageTemplate) > 0
		BEGIN
			-- insert MatchNoteUser
			EXEC dbo.OWP_MatchNoteUser_Insert @MatchNoteId = @MatchNoteId
				,@CreatorId = @UserId
				,@UserIds = @Traders
				,@ErrCode = @ErrCode OUTPUT
				,@ErrMsg = @ErrMsg OUTPUT

			-- insert message
			EXEC dbo.OWP_MessageInsert @UserId = @UserId
				,@MessageContent = @MessageTemplate
				,@MessageTo = @Traders
				,@IsImportant = 0
				,@MessageType = @MessageType
				,@SessionId = @SessionId
				,@ErrCode = @ErrCode OUTPUT
				,@ErrMsg = @ErrMsg OUTPUT
		END
	END

	SELECT @ErrMsg = @MatchNoteId

	-- For write log
	SET @Xml = (
		SELECT @OWPMatchId AS '@mt'
			,@Note AS '@nt'
			,@UserId AS '@cb'
			,GETDATE() AS '@cd'
		FOR XML PATH('z')
			,ROOT('r')
		)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @UserId
		,@SPName = 'OWP_LiveDetail_InsertMatchNote'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @MatchNoteId
		,@Data = @LogData
		,@DataOld = NULL
END