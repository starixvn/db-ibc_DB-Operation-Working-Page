
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_Assignment_Create] @ActorId INT
	,@SessionId NVARCHAR(50)
	,@OWPMatchId INT
	,@BetType INT
	,@AssignmentType TINYINT
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
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20181012@Leo.Vo: Notify assignee - [Redmine: #102867]
*/
BEGIN
	SET NOCOUNT ON

	IF EXISTS (
			SELECT 1
			FROM dbo.Assignment WITH (NOLOCK)
			WHERE OWPMatchId = @OWPMatchId
				AND Bettype = @BetType
				AND AssignmentType = @AssignmentType
				AND @AssignmentType = 1
			)
	BEGIN
		SELECT @ErrCode = 1
			,@ErrMsg = 'The main assignment is existed'

		RETURN
	END

	DECLARE @EventDateTime DATETIME
		,@MessageInsertAssignmentId INT
		,@MessageInsertAssignment NVARCHAR(500)
		,@MessageInsertOtherAssignmentId INT
		,@MessageInsertOtherAssignment NVARCHAR(500)
		,@MessageChangeOfAssignmentId INT
		,@MessageChangeOfAssignment NVARCHAR(500)
		,@FromTimeSendMessage DATETIME
		,@ToTimeSendMessage DATETIME
		,@FromTimeSendMessageSpecialBettype DATETIME
		,@ToTimeSendMessageSpecialBettype DATETIME
		,@MyAssignmentNotificationSettingId INT = 1
		,@ChangeOfAssignmentNotificationSettingId INT = 2
		,@BettypeName NVARCHAR(200)
		,@HomeTeam NVARCHAR(200)
		,@AwayTeam NVARCHAR(200)
		,@Username NVARCHAR(30)
		,@MinorBetTypeId INT
		,@ActorName NVARCHAR(30)

	INSERT INTO dbo.Assignment (
		OWPMatchId
		,Bettype
		,AssignmentType
		,UserId
		,AssignmentNote
		)
	VALUES (
		@OWPMatchId
		,@BetType
		,@AssignmentType
		,@UserId
		,@AssignmentNote
		)

	SELECT @ErrMsg = SCOPE_IDENTITY()

	SELECT @HomeTeam = h.OWPTeamName
		,@AwayTeam = a.OWPTeamName
		,@BettypeName = al.BetTypeName
		,@Username = CASE 
			WHEN u.UserId IS NULL THEN ''
			ELSE '#' + ISNULL(u.Nickname, u.Username)
			END
		,@MinorBettypeId = al.MinorBetTypeId
		,@EventDateTime = m.EventDateTime
	FROM (
		SELECT (CASE 
				WHEN mm.MinorMatchId IS NULL THEN d.OWPMatchId
				ELSE mm.ParentMatchId END
				) AS OWPMatchId
			,(CASE 
				WHEN mm.MinorMatchId IS NULL THEN mjb.ShortName
				ELSE mb.MinorBettypeName END
				) AS BetTypeName
			,d.UserId
			,mm.MinorBettypeId
		FROM (
			SELECT @OWPMatchId AS OWPMatchId
				,@BetType AS BetType
				,@UserId AS UserId
			) AS d
			LEFT JOIN dbo.MajorBettype AS mjb WITH (NOLOCK) ON d.BetType = mjb.BettypeId
			LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON d.OWPMatchId = mm.MinorMatchId
			LEFT JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mm.MinorBettypeId = mb.ParentBettypeId
			AND d.BetType = mb.InheritedBettypeId
		) AS al
		INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON al.OWPMatchId = m.OWPMatchId
		INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON h.OWPTeamId = m.OWPHomeId
		INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON a.OWPTeamId = m.OWPAwayId
		LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON u.UserId = al.UserId

	CREATE TABLE #tblMessage (
		UserId INT
		,MessageContent NVARCHAR(MAX)
		,MessageTypeId INT
		,MinorBetTypeId INT
		,EventDateTime DATETIME
		,IsImportant BIT
		)

	SELECT @MessageInsertAssignment = mt.MsgTemplateContent
		,@MessageInsertAssignmentId = mt.MsgTemplateId
	FROM dbo.MessageTemplate mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'AssignmentInsert'

	SELECT @MessageInsertOtherAssignment = mt.MsgTemplateContent
		,@MessageInsertOtherAssignmentId = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'OtherAssignmentInsert'

	SELECT @MessageChangeOfAssignment = mt.MsgTemplateContent
		,@MessageChangeOfAssignmentId = mt.MsgTemplateId
	FROM dbo.MessageTemplate mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'ChangeOfAssignment'

	-- send message to trader assigned
	IF @UserId IS NOT NULL
	BEGIN
		EXEC dbo.OWP_Trade5MatchPerDay_RunAfterInsertAssignment @EventDateTime
			,@UserId

		INSERT INTO #tblMessage (
			UserId
			,MessageContent
			,MessageTypeId
			,MinorBetTypeId
			,EventDateTime
			,IsImportant
			)
		SELECT d.UserId
			,d.MessageContent
			,d.MessageTypeId
			,d.MinorBetTypeId
			,d.EventDateTime
			,1
		FROM (
			SELECT @UserId AS UserId
				,REPLACE(CASE 
						WHEN @AssignmentNote IS NULL THEN @MessageInsertAssignment
						ELSE REPLACE(@MessageInsertOtherAssignment, '<note>', RTRIM(LTRIM(REPLACE(@AssignmentNote, '#<user>', ''))))
						END, '<event>', @HomeTeam + ' vs ' + @AwayTeam + ' - bettype: ' + @BettypeName) AS MessageContent
				,(CASE 
					WHEN @AssignmentNote IS NULL THEN @MessageInsertAssignmentId
					ELSE @MessageInsertOtherAssignmentId END
					) AS MessageTypeId
				,@MinorBetTypeId AS MinorBetTypeId
				,@EventDateTime AS EventDateTime
			) AS d
			LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @MyAssignmentNotificationSettingId
			LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			AND nsm.UserId = d.UserId
		WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
	END

	-- send message to traders have match assigned
	SELECT @ActorName = dbo.[fnc_GetUsernameByUserId](@ActorId)

	INSERT INTO #tblMessage (
		UserId
		,MessageContent
		,MessageTypeId
		,MinorBetTypeId
		,EventDateTime
		,IsImportant
		)
	SELECT d.UserId
		,d.MessageContent
		,d.MessageTypeId
		,d.MinorBetTypeId
		,d.EventDateTime
		,0
	FROM (
		SELECT UserId
			,REPLACE(REPLACE(REPLACE(REPLACE(@MessageChangeOfAssignment, '<newAssignee>', CASE 
								WHEN @AssignmentNote IS NULL THEN @Username
								ELSE RTRIM(LTRIM(REPLACE(@AssignmentNote, '#<user>', @Username)))
								END), '<event>', @HomeTeam + ' vs ' + @AwayTeam + ' - bettype: ' + @BettypeName), '<user>', @ActorName), '<oldAssignee>', '') AS MessageContent
			,@MessageChangeOfAssignmentId AS MessageTypeId
			,@MinorBetTypeId AS MinorBetTypeId
			,@EventDateTime AS EventDateTime
		FROM dbo.[fnc_GetAssigneeToSendMessage](@OWPMatchId, @ChangeOfAssignmentNotificationSettingId)
		WHERE UserId <> ISNULL(@UserId, 0)
		) AS d
		LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @MyAssignmentNotificationSettingId
		LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
		AND nsm.UserId = d.UserId
	WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'

	-- list of minor bettypes Corner & Booking but not 15 mins
	CREATE TABLE #tblCornerBookingBetTypes (MinorBetTypeId INT NOT NULL)

	INSERT INTO #tblCornerBookingBetTypes
	SELECT MinorBettypeId
	FROM dbo.MinorBettype WITH (NOLOCK)
	WHERE ParentBetTypeId IS NULL
		AND IsActive = 1
		AND MinorBettypeName NOT LIKE '%15 mins%'
		AND (
			MinorBettypeName LIKE '%corner%'
			OR MinorBettypeName LIKE '%booking%'
			)

	SELECT @FromTimeSendMessage = FromTime
		,@ToTimeSendMessage = ToTime
		,@FromTimeSendMessageSpecialBettype = FromTimeForSpecialBettype
		,@ToTimeSendMessageSpecialBettype = ToTimeForSpecialBettype
	FROM dbo.fnc_GetDateTimeForTraderViewTime()

	-- insert message
	MERGE dbo.[Message] WITH (ROWLOCK) AS ms
	USING (
		SELECT m.UserId
			,m.MessageContent
			,m.MessageTypeId
			,m.IsImportant
		FROM #tblMessage AS m
		WHERE (
				m.MinorBetTypeId IS NULL
				AND m.EventDateTime >= @FromTimeSendMessage
				AND m.EventDateTime <= @ToTimeSendMessage
				)
			OR (
				m.MinorBetTypeId IS NOT NULL
				AND 1 = (CASE 
					WHEN EXISTS (
							SELECT 1
							FROM #tblCornerBookingBetTypes
							WHERE MinorBetTypeId = m.MinorBetTypeId
							) THEN CASE 
							WHEN m.EventDateTime >= @FromTimeSendMessageSpecialBettype
								AND m.EventDateTime <= @ToTimeSendMessageSpecialBettype THEN 1
							ELSE 0
							END
					ELSE CASE 
							WHEN m.EventDateTime >= @FromTimeSendMessage
								AND m.EventDateTime <= @ToTimeSendMessage THEN 1
							ELSE 0
							END END
					)
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
				,msn.IsImportant
				,msn.MessageTypeId
				)
	OUTPUT inserted.MessageId
		,msn.UserId
		,@ActorId
		,@SessionId
	INTO dbo.MessageUser([MessageId], [UserId], [CreatedBy], [SessionId]);
END