CREATE PROCEDURE [dbo].[OWP_LiveDetail_UpdateAssignment] @UserId INT = NULL
	,@Username VARCHAR(50) = ''
	,@OWPMatchId INT
	,@Bettype INT
	,@AssignmentType TINYINT
	,@IsLive BIT
	,@ModifiedBy INT
	,@SessionId NVARCHAR(50) = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20161228@Quinn.Vo
Task: Update Assignments at Live Detail.
DB: bodb_OWP
 
Param's Explanation:
• @ErrCode:
	= 0: Transaction recorded successfully.
	> 0: Specific Error.
• @ErrMsg: Error description. 

Revisions:
	20170403@Alvin.Nguyen: return NotifyUserName, NotifyMsg 
	20170419@Tim.Trinh: modify time to send message
	20180417@leo.vo: add FM, AIO
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @owpToday DATETIME = DATEADD(hh, 12, GETDATE())
		,@StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogAssignmentData NVARCHAR(MAX)
		,@LogOldAssignmentData NVARCHAR(MAX)
		,@Xml XML
		,@OldUserId INT = NULL
		,@IsUpdate BIT = 0
		,@EventDateTime DATETIME
		,@IsSelected BIT = 0
		,@MessageInsertAssignment NVARCHAR(500)
		,@MessageDeleteAssignment NVARCHAR(500)
		,@MessageInsertAssignmentId INT
		,@MessageDeleteAssignmentId INT
		,@FromTimeSendMessage DATETIME
		,@ToTimeSendMessage DATETIME
		,@FromTimeSendMessageSpecialBettype DATETIME
		,@ToTimeSendMessageSpecialBettype DATETIME
		,@NextCornerId INT = - 4
		,@NextBookingId INT = - 7

	SET @StartRun = GETDATE()

	CREATE TABLE #tblAssignment (
		OWPMatchId INT
		,Bettype INT
		,AssignmentType INT
		,UserId INT
		,OldUserId INT
		)

	CREATE TABLE #tblDeletedAssignment (
		OWPMatchId INT
		,Bettype INT
		,AssignmentType INT
		,UserId INT
		)

	CREATE TABLE #tblInsertedAssignment (
		OWPMatchId INT
		,Bettype INT
		,AssignmentType INT
		,UserId INT
		)

	CREATE TABLE #tblMessage (
		UserId INT
		,MessageContent NVARCHAR(MAX)
		,MessageTypeId INT
		)

	SELECT @FromTimeSendMessage = FromTime
		,@ToTimeSendMessage = ToTime
		,@FromTimeSendMessageSpecialBettype = FromTimeForSpecialBettype
		,@ToTimeSendMessageSpecialBettype= ToTimeForSpecialBettype
	FROM dbo.fnc_GetDateTimeForTraderViewTime()

	SELECT @EventDateTime = DATEADD(DAY, DATEDIFF(DAY, 0, om.EventDate), CAST(om.KickOffTime AS VARCHAR(10)))
		,@IsSelected = info.IsSelected
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
		INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON om.OWPMatchId = info.OWPMatchId
	WHERE om.OWPMatchId = @OWPMatchId

	IF @UserId IS NULL
		AND @Username <> ''
	BEGIN
		SELECT @UserId = dbo.OWP_GetUserIdByUsername(@Username)

		IF ISNULL(@UserId, 0) = 0
		BEGIN
			SELECT @ErrCode = 5301
				,@ErrMsg = 'User does not exists.'

			RETURN
		END
	END

	SELECT @OldUserId = UserId
		,@IsUpdate = 1
	FROM dbo.Assignment WITH (NOLOCK)
	WHERE OWPMatchId = @OWPMatchId
		AND Bettype = @Bettype
		AND AssignmentType = @AssignmentType
		AND IsLive = @IsLive

	IF ISNULL(@UserId, 0) = ISNULL(@OldUserId, 0)
	BEGIN
		RETURN
	END

	INSERT INTO #tblAssignment (
		OWPMatchId
		,Bettype
		,AssignmentType
		,UserId
		,OldUserId
		)
	SELECT @OWPMatchId
		,@Bettype
		,@AssignmentType
		,@UserId
		,@OldUserId
	
	INSERT INTO #tblAssignment (
		OWPMatchId
		,Bettype
		,AssignmentType
		,UserId
		,OldUserId
		)
	SELECT mi.MinorMatchId
		,mib.InheritedBettypeId
		,asm.AssignmentType
		,asm.UserId
		,oas.UserId
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
		INNER JOIN dbo.MinorMatch AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.ParentMatchId
		INNER JOIN #tblAssignment AS asm WITH (NOLOCK) ON m.OWPMatchId = asm.OWPMatchId
		INNER JOIN dbo.MinorBettype AS mib WITH (NOLOCK) ON mi.MinorBettypeId = mib.ParentBettypeId
			AND mib.LinkBettypeId = asm.Bettype
		LEFT JOIN dbo.Assignment AS oas WITH (NOLOCK) ON mi.MinorMatchId = oas.OWPMatchId
			AND oas.Bettype = asm.Bettype
			AND oas.AssignmentType = asm.AssignmentType
	WHERE m.OWPMatchId = @OWPMatchId
	UNION
	SELECT
		mi1.MinorMatchId
		,mib1.InheritedBettypeId
		,asm.AssignmentType
		,asm.UserId
		,oas.UserId
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
		INNER JOIN #tblAssignment AS asm WITH (NOLOCK) ON m.OWPMatchId = asm.OWPMatchId
		INNER JOIN dbo.MinorMatch AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.MinorMatchId
		INNER JOIN dbo.MinorBettype AS mib WITH (NOLOCK) ON mi.MinorBettypeId = mib.ParentBettypeId
		INNER JOIN dbo.MinorBettype AS mib1 WITH (NOLOCK) ON mib.MinorBettypeId = mib1.LinkBettypeId
			AND mib1.InheritedBettypeId = asm.Bettype
		INNER JOIN dbo.MinorMatch AS mi1 WITH (NOLOCK) ON mi1.MinorBettypeId = mib1.ParentBettypeId
			AND mi.ParentMatchId = mi1.ParentMatchId
		LEFT JOIN dbo.Assignment AS oas WITH (NOLOCK) ON mi1.MinorMatchId = oas.OWPMatchId
			AND oas.Bettype = asm.Bettype
			AND oas.AssignmentType = asm.AssignmentType
	WHERE m.OWPMatchId = @OWPMatchId

	DELETE asm
	OUTPUT deleted.OWPMatchId
		,deleted.Bettype
		,deleted.AssignmentType
		,deleted.UserId
	INTO #tblDeletedAssignment
	FROM dbo.Assignment AS asm WITH (UPDLOCK)
	WHERE EXISTS (
			SELECT 1 FROM #tblAssignment AS a WITH (NOLOCK)
			WHERE asm.OWPMatchId = a.OWPMatchId
				AND asm.AssignmentType = a.AssignmentType
				AND asm.Bettype = a.Bettype
				AND asm.UserId <> @UserId
				--AND a.OldUserId <> @UserId
				AND asm.UserId = @OldUserId
				)
		OR EXISTS (
			SELECT 1 FROM #tblAssignment AS a WITH (NOLOCK)
			WHERE asm.OWPMatchId = a.OWPMatchId
				AND asm.AssignmentType = a.AssignmentType
				AND asm.Bettype = a.Bettype
				AND ISNULL(@UserId, 0) = 0
				AND a.OldUserId = @OldUserId
		)

	INSERT INTO dbo.Assignment (
		OWPMatchId
		,Bettype
		,AssignmentType
		,UserId
		,IsLive
		)
	OUTPUT inserted.OWPMatchId
		,inserted.Bettype
		,inserted.AssignmentType
		,inserted.UserId
	INTO #tblInsertedAssignment
	SELECT asg.OWPMatchId
		,@Bettype
		,@AssignmentType
		,asg.UserId
		,1
	FROM #tblAssignment AS asg
	WHERE (EXISTS (
			SELECT 1
			FROM dbo.Assignment WITH (NOLOCK)
			WHERE OWPMatchId = asg.OWPMatchId
				AND BetType = asg.Bettype
				AND AssignmentType = asg.AssignmentType
				AND UserId = @OldUserId
				AND UserId <> ISNULL(asg.UserId, 0)
			)
		OR NOT EXISTS (
			SELECT 1
			FROM dbo.Assignment WITH (NOLOCK)
			WHERE OWPMatchId = asg.OWPMatchId
				AND BetType = asg.Bettype
				AND AssignmentType = asg.AssignmentType
		)
		
		)
		AND asg.UserId IS NOT NULL
	
	EXEC dbo.OWP_Trade5MatchPerDay_RunAfterInsertAssignment @EventDateTime
			,@UserId

		-- send message by condition date
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

		INSERT INTO #tblMessage (
			UserId
			,MessageContent
			,MessageTypeId
			)
		SELECT u.UserId
			,REPLACE(CASE 
					WHEN asm.MinorBettypeName IS NULL AND asm.Bettype = 1 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', 'HDP')
					WHEN asm.MinorBettypeName IS NULL AND asm.Bettype = 3 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', 'OU')
					WHEN asm.MinorBettypeName IS NULL AND asm.Bettype = 5 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', '1X2')
					WHEN asm.MinorBettypeName IS NULL AND asm.Bettype = 7 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', '1H HDP')
					WHEN asm.MinorBettypeName IS NULL AND asm.Bettype = 8 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', '1H OU')
					WHEN asm.MinorBettypeName IS NULL AND asm.Bettype = 15 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', '1H 1X2')
					WHEN asm.MinorBettypeName IS NULL AND asm.Bettype = - 1001 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', '1H LA')
					WHEN asm.MinorBettypeName IS NULL AND asm.Bettype = - 1002 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', '2H LA')
					WHEN asm.MinorBettypeName IS NULL AND asm.Bettype = - 1003 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', 'FM')
					WHEN asm.MinorBettypeName IS NULL AND asm.Bettype = - 1004 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', 'AIO')
					ELSE REPLACE(@MessageDeleteAssignment, '<bettype>', asm.MinorBettypeName)
					END, '<event>', ht.OWPTeamName + ' vs ' + at.OWPTeamName)
			,@MessageDeleteAssignmentId
		FROM 
			(
				SELECT a.UserId
					,CASE WHEN minor.MinorMatchId IS NULL THEN a.OWPMatchId ELSE minor.ParentMatchId END AS OWPMatchId
					,mibt.MinorBettypeName
					,a.Bettype
				FROM #tblDeletedAssignment AS a WITH (NOLOCK)
				LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON a.OWPMatchId = minor.MinorMatchId
				LEFT JOIN dbo.MinorBettype AS mibt WITH (NOLOCK) ON minor.MinorBettypeId = mibt.ParentBettypeId AND a.Bettype = mibt.InheritedBettypeId
			) AS asm
			INNER JOIN dbo.OWPMatch AS ma WITH (NOLOCK) ON asm.OWPMatchId = ma.OWPMatchId
			INNER JOIN dbo.OWPTeam AS ht WITH (NOLOCK) ON ma.OWPHomeId = ht.OWPTeamId
			INNER JOIN dbo.OWPTeam AS at WITH (NOLOCK) ON ma.OWPAwayId = at.OWPTeamId
			INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON asm.UserId = u.UserId
		WHERE 
			EXISTS (
				SELECT 1
				FROM dbo.OWPMatch AS m WITH (NOLOCK)
					LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON minor.MinorMatchId = m.OWPMatchId
				WHERE m.OWPMatchId = @OWPMatchId
					AND 
					(
						(
							ISNULL(minor.MinorBettypeId, 0) NOT IN (@NextCornerId, @NextBookingId)
							AND @EventDateTime BETWEEN @FromTimeSendMessage AND @ToTimeSendMessage
						)
						OR
						(
							ISNULL(minor.MinorBettypeId, 0) IN (@NextCornerId, @NextBookingId)
							AND @EventDateTime BETWEEN @FromTimeSendMessageSpecialBettype AND @ToTimeSendMessageSpecialBettype
						)
					)
				)
		
		UNION
		SELECT u.UserId
			,REPLACE(CASE 
					WHEN asm.MinorBettypeName IS NULL AND asm.Bettype = 1 THEN REPLACE(@MessageInsertAssignment, '<bettype>', 'HDP')
					WHEN asm.MinorBettypeName IS NULL AND asm.Bettype = 3 THEN REPLACE(@MessageInsertAssignment, '<bettype>', 'OU')
					WHEN asm.MinorBettypeName IS NULL AND asm.Bettype = 5 THEN REPLACE(@MessageInsertAssignment, '<bettype>', '1X2')
					WHEN asm.MinorBettypeName IS NULL AND asm.Bettype = 7 THEN REPLACE(@MessageInsertAssignment, '<bettype>', '1H HDP')
					WHEN asm.MinorBettypeName IS NULL AND asm.Bettype = 8 THEN REPLACE(@MessageInsertAssignment, '<bettype>', '1H OU')
					WHEN asm.MinorBettypeName IS NULL AND asm.Bettype = 15 THEN REPLACE(@MessageInsertAssignment, '<bettype>', '1H 1X2')
					WHEN asm.MinorBettypeName IS NULL AND asm.Bettype = - 1001 THEN REPLACE(@MessageInsertAssignment, '<bettype>', '1H LA')
					WHEN asm.MinorBettypeName IS NULL AND asm.Bettype = - 1002 THEN REPLACE(@MessageInsertAssignment, '<bettype>', '2H LA')
					WHEN asm.MinorBettypeName IS NULL AND asm.Bettype = - 1003 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', 'FM')
					WHEN asm.MinorBettypeName IS NULL AND asm.Bettype = - 1004 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', 'AIO')
					ELSE REPLACE(@MessageInsertAssignment, '<bettype>', asm.MinorBettypeName)
					END, '<event>', ht.OWPTeamName + ' vs ' + at.OWPTeamName)
			,@MessageInsertAssignmentId
		FROM 
			(
				SELECT a.UserId
					,CASE WHEN minor.MinorMatchId IS NULL THEN a.OWPMatchId ELSE minor.ParentMatchId END AS OWPMatchId
					,mibt.MinorBettypeName
					,a.Bettype
				FROM #tblInsertedAssignment AS a WITH (NOLOCK)
				LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON a.OWPMatchId = minor.MinorMatchId
				LEFT JOIN dbo.MinorBettype AS mibt WITH (NOLOCK) ON minor.MinorBettypeId = mibt.ParentBettypeId AND a.Bettype = mibt.InheritedBettypeId
			) AS asm
			INNER JOIN dbo.OWPMatch AS ma WITH (NOLOCK) ON asm.OWPMatchId = ma.OWPMatchId
			INNER JOIN dbo.OWPTeam AS ht WITH (NOLOCK) ON ma.OWPHomeId = ht.OWPTeamId
			INNER JOIN dbo.OWPTeam AS at WITH (NOLOCK) ON ma.OWPAwayId = at.OWPTeamId
			INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON asm.UserId = u.UserId
		WHERE 
			EXISTS (
				SELECT 1
				FROM dbo.OWPMatch AS m WITH (NOLOCK)
					LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON minor.MinorMatchId = m.OWPMatchId
				WHERE m.OWPMatchId = @OWPMatchId
					AND 
					(
						(
							ISNULL(minor.MinorBettypeId, 0) NOT IN (@NextCornerId, @NextBookingId)
							AND @EventDateTime BETWEEN @FromTimeSendMessage AND @ToTimeSendMessage
						)
						OR
						(
							ISNULL(minor.MinorBettypeId, 0) IN (@NextCornerId, @NextBookingId)
							AND @EventDateTime BETWEEN @FromTimeSendMessageSpecialBettype AND @ToTimeSendMessageSpecialBettype
						)
					)
				)

		MERGE dbo.[Message] AS ms
		USING #tblMessage AS msn ON 1 = 0
		WHEN NOT MATCHED THEN
				INSERT (
					MessageContent
					,CreatedBy
					,CreatedDate
					,IsImportant
					,IsPermanent
					,MessageType
					)
				VALUES (
					msn.MessageContent
					,@ModifiedBy
					,GETDATE()
					,1
					,0
					,msn.MessageTypeId
					)
		OUTPUT inserted.MessageId
			,msn.UserId
			,GETDATE()
			,@ModifiedBy
			,@SessionId
		INTO dbo.MessageUser([MessageId], [UserId], [CreatedDate], [CreatedBy], [SessionId]);

		---- Log Assignment
		INSERT INTO dbo.UserLog(
			CreatorId
			,LoggedDate
			,ObjectId
			,ActionId
			,Duration
			,Data
			,DataOld
			)
		SELECT @ModifiedBy
			,GETDATE()
			,OWPMatchId
			,53
			,0
			,'<r><z mt="' + CAST(asmt.OWPMatchId AS VARCHAR(20)) + '" bt="' 
				+ CAST(asmt.Bettype AS VARCHAR(20)) + '" at="' +  CAST(asmt.AssignmentType AS VARCHAR(20)) + '" il="1" us="' 
				+ CAST(ISNULL(asmt.UserId, '') AS VARCHAR(20)) + '"/></r>'
			,'<r><z mt="' + CAST(asmt.OWPMatchId AS VARCHAR(20)) + '" bt="' 
			+ CAST(asmt.Bettype AS VARCHAR(20)) + '" at="' +  CAST(asmt.AssignmentType AS VARCHAR(20))  + '" il="1" us="' 
			+ CAST(ISNULL(asmt.OldUserId, '') AS VARCHAR(20)) + '"/></r>'
		FROM #tblAssignment AS asmt WITH (NOLOCK)
		WHERE ISNULL(asmt.UserId, 0) <> ISNULL(asmt.OldUserId, 0)

	-- write log
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @ModifiedBy
		,@SPName = 'OWP_LiveDetail_UpdateAssignment'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @OWPMatchId
		,@Data = @LogAssignmentData
		,@DataOld = @LogOldAssignmentData

		DROP TABLE #tblAssignment
		DROP TABLE #tblInsertedAssignment
		DROP TABLE #tblDeletedAssignment
		DROP TABLE #tblMessage
END