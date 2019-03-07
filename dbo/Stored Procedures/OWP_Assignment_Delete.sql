/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_Assignment_Delete] @ActorId INT
	,@SessionId NVARCHAR(50)
	,@AssignmentId INT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20180816@Leo
Task: Delete Assignment at Live Detail.
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20181012@Leo.Vo: Notify assignee - [Redmine: #102867]
	20181123@Leo.Vo: Fix notify message assignee - [Redmine: #104291]
	20181126@Leo.Vo: Seperate change of assignment LA & Trader - [Redmine: #105043]
	20190213@Kane.Le: remove createdDate vs CreatedBy table MessageUser - [Redmine: #108723]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @EventDateTime DATETIME
		,@MessageDeleteAssignmentId INT
		,@MessageDeleteAssignment NVARCHAR(500)
		,@MessageDeleteOtherAssignmentId INT
		,@MessageDeleteOtherAssignment NVARCHAR(500)
		,@MessageChangeOfAssignmentId INT
		,@MessageChangeOfAssignment NVARCHAR(500)
		,@FromTimeSendMessage DATETIME
		,@ToTimeSendMessage DATETIME
		,@FromTimeSendMessageSpecialBettype DATETIME
		,@ToTimeSendMessageSpecialBettype DATETIME
		,@OWPMatchId INT
		,@Bettype INT
		,@AssignmentType INT
		,@MyAssignmentNotificationSettingId INT = 1
		,@ChangeOfTraderAssignmentNotificationSettingId INT = 2
		,@ChangeOfLAAssignmentNotificationSettingId INT = 10
		,@BettypeName NVARCHAR(200)
		,@HomeTeam NVARCHAR(200)
		,@AwayTeam NVARCHAR(200)
		,@MinorBetTypeId INT
		,@ActorName NVARCHAR(30)
		,@ChangeOfAssignmentNotificationSettingId INT
		,@BettypeLA INT = - 1002

	SELECT @OWPMatchId = OWPMatchId
		,@Bettype = Bettype
		,@AssignmentType = AssignmentType
	FROM dbo.Assignment WITH (NOLOCK)
	WHERE AssignmentId = @AssignmentId

	IF @OWPMatchId IS NULL
	BEGIN
		SELECT @ErrCode = 1
			,@ErrMsg = 'Assignment is not existed or deleted'

		RETURN
	END

	CREATE TABLE #RemoveAssignment (
		AssignmentId INT
		,Bettype INT NOT NULL
		,AssignmentType TINYINT NOT NULL
		,UserId INT
		,AssignmentNote NVARCHAR(200)
		);

	DELETE
	FROM dbo.Assignment WITH (ROWLOCK)
	OUTPUT deleted.AssignmentId
		,deleted.Bettype
		,deleted.AssignmentType
		,deleted.UserId
		,deleted.AssignmentNote
	INTO #RemoveAssignment(AssignmentId, Bettype, AssignmentType, UserId, AssignmentNote)
	WHERE AssignmentId = @AssignmentId

	IF @AssignmentType = 1
	BEGIN
		-- remove other assignments
		DELETE
		FROM dbo.Assignment WITH (ROWLOCK)
		OUTPUT deleted.AssignmentId
			,deleted.Bettype
			,deleted.AssignmentType
			,deleted.UserId
			,deleted.AssignmentNote
		INTO #RemoveAssignment(AssignmentId, Bettype, AssignmentType, UserId, AssignmentNote)
		WHERE OWPMatchId = @OWPMatchId
			AND Bettype = @Bettype
	END

	SELECT @HomeTeam = h.OWPTeamName
		,@AwayTeam = a.OWPTeamName
		,@BettypeName = al.BetTypeName
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
			,mm.MinorBettypeId
		FROM (
			SELECT @OWPMatchId AS OWPMatchId
				,@BetType AS BetType
			) AS d
			LEFT JOIN dbo.MajorBettype AS mjb WITH (NOLOCK) ON d.BetType = mjb.BettypeId
			LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON d.OWPMatchId = mm.MinorMatchId
			LEFT JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mm.MinorBettypeId = mb.ParentBettypeId
			AND d.BetType = mb.InheritedBettypeId
		) AS al
		INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON al.OWPMatchId = m.OWPMatchId
		INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON h.OWPTeamId = m.OWPHomeId
		INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON a.OWPTeamId = m.OWPAwayId

	CREATE TABLE #tblMessage (
		UserId INT
		,MessageContent NVARCHAR(MAX)
		,MessageTypeId INT
		,MinorBetTypeId INT
		,EventDateTime DATETIME
		,IsImportant BIT
		)

	SELECT @MessageDeleteAssignment = mt.MsgTemplateContent
		,@MessageDeleteAssignmentId = mt.MsgTemplateId
	FROM dbo.MessageTemplate mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'AssignmentDelete'

	SELECT @MessageDeleteOtherAssignment = mt.MsgTemplateContent
		,@MessageDeleteOtherAssignmentId = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'OtherAssignmentDelete'

	SELECT @MessageChangeOfAssignment = mt.MsgTemplateContent
		,@MessageChangeOfAssignmentId = mt.MsgTemplateId
	FROM dbo.MessageTemplate mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'ChangeOfAssignment'

	-- send message to trader unassigned
	INSERT INTO #tblMessage (
		UserId
		,MessageContent
		,MessageTypeId
		,MinorBetTypeId
		,EventDateTime
		,IsImportant
		)
	SELECT a.UserId
		,REPLACE(CASE 
				WHEN a.AssignmentType = 1 THEN @MessageDeleteAssignment
				ELSE REPLACE(@MessageDeleteOtherAssignment, '<note>', RTRIM(LTRIM(REPLACE(a.AssignmentNote, '#<user>', ''))))
				END, '<event>', @HomeTeam + ' vs ' + @AwayTeam + ' - bettype: ' + @BettypeName)
		,CASE 
			WHEN a.AssignmentType = 1 THEN @MessageDeleteAssignmentId
			ELSE @MessageDeleteOtherAssignmentId
			END
		,@MinorBetTypeId
		,@EventDateTime
		,1
	FROM #RemoveAssignment AS a
		LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @MyAssignmentNotificationSettingId
		LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
		AND nsm.UserId = a.UserId
	WHERE a.UserId IS NOT NULL
		AND ISNULL(nsm.Value, ns.DefaultValue) = 'True'

	-- send message to traders have match assigned
	SELECT @ActorName = dbo.[fnc_GetUsernameByUserId](@ActorId)

	SELECT @ChangeOfAssignmentNotificationSettingId = CASE 
			WHEN @BetType = @BettypeLA THEN @ChangeOfLAAssignmentNotificationSettingId
			ELSE @ChangeOfTraderAssignmentNotificationSettingId
			END

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
		SELECT u.UserId
			,REPLACE(REPLACE(REPLACE(REPLACE(@MessageChangeOfAssignment, '<oldAssignee>', CASE 
								WHEN s.AssignmentNote IS NULL THEN '#' + ISNULL(us.Nickname, us.Username)
								ELSE RTRIM(LTRIM(REPLACE(s.AssignmentNote, '#<user>', CASE 
													WHEN us.UserId IS NULL THEN ''
													ELSE '#' + ISNULL(us.Nickname, us.Username)
													END)))
								END), '<event>', @HomeTeam + ' vs ' + @AwayTeam + ' - bettype: ' + @BettypeName), '<user>', @ActorName), '<newAssignee>', '') AS MessageContent
			,@MessageChangeOfAssignmentId AS MessageTypeId
			,@MinorBetTypeId AS MinorBetTypeId
			,@EventDateTime AS EventDateTime
		FROM #RemoveAssignment AS s
			CROSS JOIN dbo.[fnc_GetAssigneeToSendMessage](@OWPMatchId, @ChangeOfAssignmentNotificationSettingId) AS u
			LEFT JOIN dbo.[User] AS us WITH (NOLOCK) ON s.UserId = us.UserId
		WHERE u.UserId <> ISNULL(s.UserId, 0)
		) AS d

	-- insert message
	SELECT @FromTimeSendMessage = FromTime
		,@ToTimeSendMessage = ToTime
		,@FromTimeSendMessageSpecialBettype = FromTimeForSpecialBettype
		,@ToTimeSendMessageSpecialBettype = ToTimeForSpecialBettype
	FROM dbo.fnc_GetDateTimeForTraderViewTime()

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
		,@SessionId
	INTO dbo.MessageUser([MessageId], [UserId],  [SessionId]);

	DROP TABLE #RemoveAssignment;
END