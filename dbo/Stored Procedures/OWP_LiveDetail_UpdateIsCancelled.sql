CREATE PROCEDURE [dbo].[OWP_LiveDetail_UpdateIsCancelled] @UserId INT
	,@SessionId NVARCHAR(100)
	,@OWPMatchId INT
	,@MatchStatus NVARCHAR(15)
AS
/*
Created: 20170824@Tim.Trinh
Task : update IsCancelled 
DB: bodb_OWP

Revisions:
    20180723@Raymond.Le: Fix send notification match cancel/postponed/suspended
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @OldMatchStatus NVARCHAR(15)
		,@EventDateTime DATETIME
		,@MatchName NVARCHAR(MAX)
		-- message template
		,@MessageInsertAssignment NVARCHAR(MAX)
		,@MessageInsertAssignmentId INT
		,@MessageMatchStatus NVARCHAR(MAX)
		,@MessageMatchStatusId INT
		-- send message by condition date
		,@FromTimeSendMessage DATETIME
		,@ToTimeSendMessage DATETIME
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@NoOfCorners INT = - 3
		,@TotalBooking INT = - 6
		,@Specific15MinsNoOfCorners INT = - 5
		,@Specific15MinsTotalBooking INT = - 8
		-- Match Status
		,@str_Live NVARCHAR(15) = 'Live'
		,@str_Cancel NVARCHAR(15) = 'Cancel'
		,@str_Postponed NVARCHAR(15) = 'Postponed'
		,@str_Suspended NVARCHAR(15) = 'Suspended'

	CREATE TABLE #tblMessage (
		UserId INT
		,MessageContent NVARCHAR(MAX)
		,MessageTypeId INT
		)

	CREATE TABLE #tblOldMatchInfo (
		OWPMatchId INT
		,MatchStatus NVARCHAR(15)
		)

	SELECT @OldMatchStatus = m.MatchStatus
	FROM dbo.MatchInfo AS m WITH (NOLOCK)
	WHERE m.OWPMatchId = @OWPMatchId

	UPDATE dbo.MatchInfo WITH (ROWLOCK, UPDLOCK)
	SET MatchStatus = @MatchStatus
	OUTPUT deleted.OWPMatchId
		,deleted.MatchStatus
	INTO #tblOldMatchInfo
	WHERE OWPMatchId = @OWPMatchId

	-- send message by condition date
	SELECT @EventDateTime = om.EventDateTime
		,@MatchName = (CASE 
			WHEN LEN(ISNULL(om.MatchNo, '')) = '' THEN ''
			ELSE om.MatchNo + ' - ' END
			) + home.OWPTeamName + ' vs ' + away.OWPTeamName
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
		INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
		INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
	WHERE om.OWPMatchId = @OWPMatchId

	SELECT @FromTimeSendMessage = FromTime
		,@ToTimeSendMessage = ToTimeForSpecialBettype
	FROM dbo.fnc_GetDateTimeForTraderViewTime()

	IF @OldMatchStatus <> @MatchStatus
	BEGIN
		IF @MatchStatus = @str_Live
		BEGIN
			UPDATE info WITH (ROWLOCK, UPDLOCK)
			SET info.MatchStatus = @str_Live
			FROM dbo.MatchInfo AS info
				INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON info.OWPMatchId = minor.MinorMatchId
				AND minor.MinorBettypeId IN (@Specific10Mins, @Specific15Mins)

			IF (
					@EventDateTime BETWEEN @FromTimeSendMessage -- SEND message when on time range
						AND @ToTimeSendMessage
					)
			BEGIN
				SELECT @MessageInsertAssignment = mt.MsgTemplateContent
					,@MessageInsertAssignmentId = mt.MsgTemplateId
				FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
				WHERE mt.MsgTemplateCode = 'AssignmentInsert'

				INSERT INTO #tblMessage (
					UserId
					,MessageContent
					,MessageTypeId
					)
				SELECT asm.UserId
					,REPLACE(REPLACE(@MessageInsertAssignment, '<bettype>', asm.BettypeName), '<event>', @MatchName)
					,@MessageInsertAssignmentId
				FROM (
					SELECT a.UserId
						,mibt.MinorBettypeName AS BettypeName
						,a.Bettype
					FROM dbo.Assignment AS a WITH (NOLOCK)
						INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON a.OWPMatchId = minor.MinorMatchId
						INNER JOIN dbo.MinorBettype AS mibt WITH (NOLOCK) ON minor.MinorBettypeId = mibt.ParentBettypeId
						AND a.Bettype = mibt.InheritedBettypeId
						INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
					WHERE minor.ParentMatchId = @OWPMatchId
						AND minor.MinorBettypeId IN (@Specific10Mins, @Specific15Mins)
					
					UNION
					SELECT a.UserId
						,bt.ShortName AS BettypeName
						,a.Bettype
					FROM dbo.Assignment AS a WITH (NOLOCK)
						INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON a.OWPMatchId = m.OWPMatchId
						INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
						INNER JOIN dbo.MajorBettype AS bt WITH (NOLOCK) ON a.Bettype = bt.BettypeId
					WHERE m.OWPMatchId = @OWPMatchId
					) AS asm

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
							,@UserId
							,GETDATE()
							,1
							,0
							,msn.MessageTypeId
							)
				OUTPUT inserted.MessageId
					,msn.UserId
					,GETDATE()
					,@UserId
					,@SessionId
				INTO dbo.MessageUser(MessageId, UserId, CreatedDate, CreatedBy, SessionId);
			END
		END
		ELSE
		BEGIN
			-- Update status of minor match
			UPDATE info WITH (ROWLOCK, UPDLOCK)
			SET info.MatchStatus = @MatchStatus
			OUTPUT deleted.OWPMatchId
				,deleted.MatchStatus
			INTO #tblOldMatchInfo
			FROM dbo.MatchInfo AS info
				INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON info.OWPMatchId = minor.MinorMatchId
			WHERE minor.ParentMatchId = @OWPMatchId

			-- SEND message when on time range
			IF (
					@EventDateTime BETWEEN @FromTimeSendMessage
						AND @ToTimeSendMessage
					)
			BEGIN
				SELECT @MessageMatchStatus = mt.MsgTemplateContent
					,@MessageMatchStatusId = mt.MsgTemplateId
				FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
				WHERE mt.MsgTemplateCode = 'MatchStatus'

				-- Get message content
				INSERT INTO #tblMessage (
					UserId
					,MessageContent
					,MessageTypeId
					)
				SELECT asm.UserId
					,REPLACE(REPLACE(@MessageMatchStatus, '<event>', (CASE 
								WHEN LEN(ISNULL(om.MatchNo, '')) = 0 THEN ''
								ELSE om.MatchNo + ' - ' END
								) + home.OWPTeamName + ' vs ' + away.OWPTeamName), '<status>', info.MatchStatus)
					,@MessageMatchStatusId
				FROM (
					SELECT DISTINCT a.UserId
						,(CASE 
							WHEN minor.MinorBettypeId IN (@Specific15Mins, @Specific10Mins) THEN minor.ParentMatchId
							WHEN minor.MinorBettypeId IN (@Specific15MinsNoOfCorners, @Specific15MinsTotalBooking) THEN mparent.MinorMatchId
							ELSE a.OWPMatchId END
							) AS OWPMatchId
					FROM dbo.Assignment AS a WITH (NOLOCK)
						INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON a.OWPMatchId = minor.MinorMatchId
						LEFT JOIN dbo.MinorMatch AS mparent WITH (NOLOCK) ON mparent.ParentMatchId = minor.ParentMatchId
						AND (
							(
								minor.MinorBettypeId = @Specific15MinsNoOfCorners
								AND mparent.MinorBettypeId = @NoOfCorners
								)
							OR (
								minor.MinorBettypeId = @Specific15MinsTotalBooking
								AND mparent.MinorBettypeId = @TotalBooking
								)
							)
					WHERE minor.ParentMatchId = @OWPMatchId
					
					UNION
					SELECT DISTINCT a.UserId
						,a.OWPMatchId
					FROM dbo.Assignment AS a WITH (NOLOCK)
					WHERE a.OWPMatchId = @OWPMatchId
					) AS asm
					INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON asm.OWPMatchId = om.OWPMatchId
					INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON asm.OWPMatchId = info.OWPMatchId
					INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
					INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
					LEFT JOIN #tblOldMatchInfo AS oldinfo ON asm.OWPMatchId = oldinfo.OWPMatchId
				WHERE info.MatchStatus <> oldinfo.MatchStatus -- NOTE: (to send message to match has diff status)

				-- insert into table Message & MessageUser
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
							,@UserId
							,GETDATE()
							,1
							,0
							,msn.MessageTypeId
							)
				OUTPUT inserted.MessageId
					,msn.UserId
					,GETDATE()
					,@UserId
					,@SessionId
				INTO dbo.MessageUser(MessageId, UserId, CreatedDate, CreatedBy, SessionId);
			END
		END
	END

	DROP TABLE #tblMessage

	DROP TABLE #tblOldMatchInfo
END