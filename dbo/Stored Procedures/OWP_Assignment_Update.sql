/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_Assignment_Update] @ActorId INT
	,@SessionId VARCHAR(50)
	,@AssignmentId INT
	,@UserId INT = NULL
	,@AssignmentNote NVARCHAR(200) = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20180816@Leo
Task: Update Assignments at Live Detail.
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: new structure
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @owpToday DATETIME = DATEADD(hh, 12, GETDATE())
		,@OldUserId INT = NULL
		,@OldAssignmentNote NVARCHAR(200)
		,@EventDateTime DATETIME
		,@MessageInsertAssignmentId INT
		,@MessageInsertAssignment NVARCHAR(500)
		,@MessageDeleteAssignmentId INT
		,@MessageDeleteAssignment NVARCHAR(500)
		,@MessageInsertOtherAssignmentId INT
		,@MessageInsertOtherAssignment NVARCHAR(500)
		,@MessageDeleteOtherAssignmentId INT
		,@MessageDeleteOtherAssignment NVARCHAR(500)
		,@MessageUpdateOtherAssignmentId INT
		,@MessageUpdateOtherAssignment NVARCHAR(500)
		,@FromTimeSendMessage DATETIME
		,@ToTimeSendMessage DATETIME
		,@FromTimeSendMessageSpecialBettype DATETIME
		,@ToTimeSendMessageSpecialBettype DATETIME
		,@OWPMatchId INT


	SELECT @OWPMatchId = OWPMatchId
		,@OldUserId = UserId
		,@OldAssignmentNote = AssignmentNote
	FROM dbo.Assignment WITH (NOLOCK)
	WHERE AssignmentId = @AssignmentId

	IF @OWPMatchId IS NULL
	BEGIN
		SELECT @ErrCode = 1
			,@ErrMsg = 'Assignment is not existed or deleted'

		RETURN
	END


	UPDATE dbo.Assignment WITH (ROWLOCK)
	SET UserId = @UserId
		,AssignmentNote = @AssignmentNote
	WHERE AssignmentId = @AssignmentId AND (UserId <> @UserId OR AssignmentNote <> @AssignmentNote)


	IF(@@ROWCOUNT = 0) RETURN

	
	IF @UserId IS NOT NULL
	BEGIN
		EXEC dbo.OWP_Trade5MatchPerDay_RunAfterInsertAssignment @EventDateTime, @UserId
	END


	-- list of minor bettypes Corner & Booking but not 15 mins
	CREATE TABLE #tblCornerBookingBetTypes (
		MinorBetTypeId INT NOT NULL
	)
	INSERT INTO #tblCornerBookingBetTypes
	SELECT MinorBettypeId FROM dbo.MinorBettype WITH (NOLOCK)
	WHERE ParentBetTypeId IS NULL
		AND IsActive = 1
		AND MinorBettypeName NOT LIKE '%15 mins%'
		AND (MinorBettypeName LIKE '%corner%' OR MinorBettypeName LIKE '%booking%')


	CREATE TABLE #tblMessage (
		UserId INT
		,MessageContent NVARCHAR(MAX)
		,MessageTypeId INT
		,MinorBetTypeId INT
		,EventDateTime DATETIME
		)

	SELECT @EventDateTime = DATEADD(DAY, DATEDIFF(DAY, 0, om.EventDate), CAST(om.KickOffTime AS VARCHAR(10)))
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
		INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON om.OWPMatchId = info.OWPMatchId
	WHERE om.OWPMatchId = @OWPMatchId

	SELECT @FromTimeSendMessage = FromTime
		,@ToTimeSendMessage = ToTime
		,@FromTimeSendMessageSpecialBettype = FromTimeForSpecialBettype
		,@ToTimeSendMessageSpecialBettype= ToTimeForSpecialBettype
	FROM dbo.fnc_GetDateTimeForTraderViewTime()

	SELECT @MessageInsertAssignment = mt.MsgTemplateContent
		,@MessageInsertAssignmentId = mt.MsgTemplateId
	FROM dbo.MessageTemplate mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'AssignmentInsert'

	SELECT @MessageDeleteAssignment = mt.MsgTemplateContent
		,@MessageDeleteAssignmentId = mt.MsgTemplateId
	FROM dbo.MessageTemplate mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'AssignmentDelete'

	SELECT @MessageInsertOtherAssignment = mt.MsgTemplateContent
		,@MessageInsertOtherAssignmentId = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'OtherAssignmentInsert'

	SELECT @MessageDeleteOtherAssignment = mt.MsgTemplateContent
		,@MessageDeleteOtherAssignmentId = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'OtherAssignmentDelete'

	SELECT @MessageUpdateOtherAssignment = mt.MsgTemplateContent
		,@MessageUpdateOtherAssignmentId = mt.MsgTemplateId
	FROM dbo.MessageTemplate mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'OtherAssignmentUpdate'


	-- send message to trader unassigned
	INSERT INTO #tblMessage (
		UserId
		,MessageContent
		,MessageTypeId
		,MinorBetTypeId
		,EventDateTime
	)
	SELECT u.UserId
		,REPLACE
			(REPLACE
				(CASE WHEN al.AssignmentNote IS NULL 
				THEN @MessageDeleteAssignment
				ELSE REPLACE(@MessageDeleteOtherAssignment, '<note>', RTRIM(LTRIM(REPLACE(al.AssignmentNote, '#<user>', '')))) END
				,'<bettype>'
				,al.BetTypeName)
			,'<event>'
			, h.OWPTeamName + ' vs ' + a.OWPTeamName)
		,CASE WHEN al.AssignmentNote IS NULL
			THEN @MessageDeleteAssignmentId
			ELSE @MessageDeleteOtherAssignmentId
			END
		,al.MinorBetTypeId
		,m.EventDateTime
	FROM (
	SELECT (CASE WHEN mm.MinorMatchId IS NULL
				THEN d.OWPMatchId
				ELSE mm.ParentMatchId
				END) AS OWPMatchId
			,(CASE WHEN mm.MinorMatchId IS NULL
				THEN mjb.ShortName
				ELSE mb.MinorBettypeName
				END) AS BetTypeName
			,d.UserId
			,d.AssignmentNote
			,mm.MinorBettypeId
		FROM (
			SELECT OWPMatchId
				,BetType
				,@OldUserId AS UserId
				,@OldAssignmentNote AS AssignmentNote
			FROM dbo.Assignment AS a WITH (NOLOCK)
			WHERE a.AssignmentId = @AssignmentId AND @OldUserId IS NOT NULL AND @OldUserId <> @UserId) AS d
		LEFT JOIN dbo.MajorBettype AS mjb WITH (NOLOCK) ON d.BetType = mjb.BettypeId
		LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON d.OWPMatchId = mm.MinorMatchId
		LEFT JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mm.MinorBettypeId = mb.ParentBettypeId
			AND d.BetType = mb.InheritedBettypeId
		) AS al
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON al.OWPMatchId = m.OWPMatchId
	INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON h.OWPTeamId = m.OWPHomeId
	INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON a.OWPTeamId = m.OWPAwayId
	INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON u.UserId = al.UserId


	-- send message to trader assigned
	INSERT INTO #tblMessage (
		UserId
		,MessageContent
		,MessageTypeId
		,MinorBetTypeId
		,EventDateTime
	)
	SELECT u.UserId
		,REPLACE
			(REPLACE
				(CASE WHEN al.AssignmentNote IS NULL 
				THEN @MessageInsertAssignment
				ELSE REPLACE(@MessageInsertOtherAssignment, '<note>', RTRIM(LTRIM(REPLACE(al.AssignmentNote, '#<user>', '')))) END
				,'<bettype>'
				,al.BetTypeName)
			,'<event>'
			, h.OWPTeamName + ' vs ' + a.OWPTeamName)
		,CASE WHEN al.AssignmentNote IS NULL
			THEN @MessageInsertAssignmentId
			ELSE @MessageInsertOtherAssignmentId
			END
		,al.MinorBetTypeId
		,m.EventDateTime
	FROM (
	SELECT (CASE WHEN mm.MinorMatchId IS NULL
				THEN d.OWPMatchId
				ELSE mm.ParentMatchId
				END) AS OWPMatchId
			,(CASE WHEN mm.MinorMatchId IS NULL
				THEN mjb.ShortName
				ELSE mb.MinorBettypeName
				END) AS BetTypeName
			,d.UserId
			,d.AssignmentNote
			,mm.MinorBettypeId
		FROM (
			SELECT OWPMatchId
				,BetType
				,UserId
				,AssignmentNote
			FROM dbo.Assignment AS a WITH (NOLOCK)
			WHERE a.AssignmentId = @AssignmentId AND UserId IS NOT NULL AND UserId <> @OldUserId) AS d
		LEFT JOIN dbo.MajorBettype AS mjb WITH (NOLOCK) ON d.BetType = mjb.BettypeId
		LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON d.OWPMatchId = mm.MinorMatchId
		LEFT JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mm.MinorBettypeId = mb.ParentBettypeId
			AND d.BetType = mb.InheritedBettypeId
		) AS al
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON al.OWPMatchId = m.OWPMatchId
	INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON h.OWPTeamId = m.OWPHomeId
	INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON a.OWPTeamId = m.OWPAwayId
	INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON u.UserId = al.UserId


	-- send message to trader edited
	INSERT INTO #tblMessage (
		UserId
		,MessageContent
		,MessageTypeId
		,MinorBetTypeId
		,EventDateTime
	)
	SELECT u.UserId
		,REPLACE
			(REPLACE
				(REPLACE(
					REPLACE(@MessageUpdateOtherAssignment, '<newnote>', RTRIM(LTRIM(REPLACE(al.AssignmentNote, '#<user>', '')))), '<oldnote>', RTRIM(LTRIM(REPLACE(@OldAssignmentNote, '#<user>', ''))))
				,'<bettype>'
				,al.BetTypeName)
			,'<event>'
			, h.OWPTeamName + ' vs ' + a.OWPTeamName)
		,@MessageUpdateOtherAssignmentId
		,al.MinorBetTypeId
		,m.EventDateTime
	FROM (
	SELECT (CASE WHEN mm.MinorMatchId IS NULL
				THEN d.OWPMatchId
				ELSE mm.ParentMatchId
				END) AS OWPMatchId
			,(CASE WHEN mm.MinorMatchId IS NULL
				THEN mjb.ShortName
				ELSE mb.MinorBettypeName
				END) AS BetTypeName
			,d.UserId
			,d.AssignmentNote
			,mm.MinorBettypeId
		FROM (
			SELECT OWPMatchId
				,BetType
				,UserId
				,AssignmentNote
			FROM dbo.Assignment AS a WITH (NOLOCK)
			WHERE a.AssignmentId = @AssignmentId AND UserId IS NOT NULL AND UserId = @OldUserId) AS d
		LEFT JOIN dbo.MajorBettype AS mjb WITH (NOLOCK) ON d.BetType = mjb.BettypeId
		LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON d.OWPMatchId = mm.MinorMatchId
		LEFT JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mm.MinorBettypeId = mb.ParentBettypeId
			AND d.BetType = mb.InheritedBettypeId
		) AS al
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON al.OWPMatchId = m.OWPMatchId
	INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON h.OWPTeamId = m.OWPHomeId
	INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON a.OWPTeamId = m.OWPAwayId
	INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON u.UserId = al.UserId
	

	-- insert message
	MERGE dbo.[Message] WITH (ROWLOCK) AS ms
	USING (SELECT m.UserId
			,m.MessageContent
			,m.MessageTypeId
		FROM #tblMessage AS m
		WHERE (m.MinorBetTypeId IS NULL 
			AND m.EventDateTime >= @FromTimeSendMessage
			AND m.EventDateTime <= @ToTimeSendMessage
		)
		OR (m.MinorBetTypeId IS NOT NULL
			AND 1 = (CASE WHEN EXISTS (
						SELECT 1 FROM #tblCornerBookingBetTypes
						WHERE MinorBetTypeId = m.MinorBetTypeId)
					THEN
						CASE WHEN m.EventDateTime >= @FromTimeSendMessageSpecialBettype
							AND m.EventDateTime <= @ToTimeSendMessageSpecialBettype
						THEN 1
						ELSE 0
						END
					ELSE
						CASE WHEN m.EventDateTime >= @FromTimeSendMessage
							AND m.EventDateTime <= @ToTimeSendMessage
						THEN 1
						ELSE 0
						END
					END)
		)
	) AS msn ON 1 = 0
	WHEN NOT MATCHED THEN
		INSERT (
			MessageContent
			,CreatedBy
			,IsImportant
			,MessageType
			)
		VALUES (
			msn.MessageContent
			,@ActorId
			,1
			,msn.MessageTypeId
			)
	OUTPUT inserted.MessageId
		,msn.UserId
		,@ActorId
		,@SessionId
	INTO dbo.MessageUser([MessageId], [UserId], [CreatedBy], [SessionId]);
END