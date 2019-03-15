/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_MatchInfo_UpdateMatchStatus] @UserId INT
	,@SessionId NVARCHAR(100)
	,@OWPMatchId INT
	,@MatchStatus NVARCHAR(15)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20170824@Tim.Trinh
Task : update Match status 
DB: bodb_OWP

Revisions:
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20181012@Leo.Vo: Notify assignee - [Redmine: #102867]
	20190213@Kane.Le: remove createdDate vs CreatedBy table MessageUser - [Redmine: #108723]
	20190308@Kane.Le: add Notification Watcher - [Redmine: #109560]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @OldMatchStatus NVARCHAR(15)
		,@EventDateTime DATETIME
		,@MatchName NVARCHAR(MAX)
		-- message template
		,@MessageInsertAssignment NVARCHAR(MAX)
		,@MessageInsertAssignmentId INT
		,@MessageInsertOtherAssignment NVARCHAR(MAX)
		,@MessageInsertOtherAssignmentId INT
		,@MessageMatchStatus NVARCHAR(MAX)
		,@MessageMatchStatusId INT
		,@MessageMinorMatchStatus NVARCHAR(MAX)
		,@MessageMinorMatchStatusId INT
		-- send message by condition date
		,@FromTimeSendMessage DATETIME
		,@ToTimeSendMessage DATETIME
		,@FromTimeSendMessageSpecialBettype DATETIME
		,@ToTimeSendMessageSpecialBettype DATETIME
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@FastMarket INT = - 88
		,@AllInOne INT = - 89
		,@NoOfCorners INT = - 3
		,@TotalBooking INT = - 6
		,@Specific15MinsNoOfCorners INT = - 5
		,@Specific15MinsTotalBooking INT = - 8
		-- Match Status
		,@str_Live NVARCHAR(15) = 'Live'
		,@str_Cancel NVARCHAR(15) = 'Cancel'
		,@str_Postponed NVARCHAR(15) = 'Postponed'
		,@str_Suspended NVARCHAR(15) = 'Suspended'
		,@NotifyMyAssignmentUpdatedId INT = 1 
		,@NotifyAssigneeMatchInfoUpdatedId SMALLINT = 5
		,@NotifyWatcherMatchInfoUpdatedId SMALLINT = 9
		,@UserReceivedAssigneeMessageMatchInfo TVP_INT
		,@UserReceivedWatcherMessageMatchInfo TVP_INT

	CREATE TABLE #tblMessage (
		UserId INT
		,MessageContent NVARCHAR(MAX)
		,MessageTypeId INT
		,MinorBettypeId INT
		,EventDateTime DATETIME
		)

	CREATE TABLE #tblOldMatchInfo (
		OWPMatchId INT
		,MatchStatus NVARCHAR(15)
		)

	CREATE TABLE #tbChangeMatchStatusMessage (
		Id INT IDENTITY(1, 1)
		,OWPMatchId INT
		,MinorBettypeId INT
		,MessageContent NVARCHAR(2000)
		,MessageTypeId INT
		)

	CREATE TABLE #tblAllAssigneeOfMatch (UserId INT NOT NULL)

	CREATE TABLE #tblSectionMemberOfUserReceivedWatcher (
		MemberId INT
		,UserReceivedWatcherId INT
		)

	-- list of minor bettypes Corner & Booking but not 15 mins
	CREATE TABLE #tblCornerBookingBetTypes (MinorBettypeId INT NOT NULL)

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

	BEGIN TRY
		SELECT @OldMatchStatus = m.MatchStatus
		FROM dbo.MatchInfo AS m WITH (NOLOCK)
		WHERE m.OWPMatchId = @OWPMatchId

		UPDATE dbo.MatchInfo WITH (ROWLOCK, UPDLOCK)
		SET MatchStatus = @MatchStatus
		OUTPUT deleted.OWPMatchId
			,deleted.MatchStatus
		INTO #tblOldMatchInfo
		WHERE OWPMatchId = @OWPMatchId

		-- Get Main match name 
		SELECT @EventDateTime = om.EventDateTime
			,@MatchName = home.OWPTeamName + ' vs ' + away.OWPTeamName
		FROM dbo.OWPMatch AS om WITH (NOLOCK)
			INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
			INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
		WHERE om.OWPMatchId = @OWPMatchId

		IF @OldMatchStatus <> @MatchStatus
		BEGIN
			-- send message by condition date
			SELECT @FromTimeSendMessage = FromTime
				,@ToTimeSendMessage = ToTime
				,@FromTimeSendMessageSpecialBettype = FromTimeForSpecialBettype
				,@ToTimeSendMessageSpecialBettype = ToTimeForSpecialBettype
			FROM dbo.fnc_GetDateTimeForTraderViewTime()

			IF @MatchStatus = @str_Live
			BEGIN
				UPDATE info WITH (ROWLOCK, UPDLOCK)
				SET info.MatchStatus = @str_Live
				FROM dbo.MatchInfo AS info
					INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON info.OWPMatchId = minor.MinorMatchId
					AND minor.MinorBettypeId IN (@Specific10Mins, @Specific15Mins, @FastMarket, @AllInOne)

				-- SEND message when on time range
				SELECT @MessageInsertAssignment = mt.MsgTemplateContent
					,@MessageInsertAssignmentId = mt.MsgTemplateId
				FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
				WHERE mt.MsgTemplateCode = 'AssignmentInsert'

				SELECT @MessageInsertOtherAssignment = mt.MsgTemplateContent
					,@MessageInsertOtherAssignmentId = mt.MsgTemplateId
				FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
				WHERE mt.MsgTemplateCode = 'OtherAssignmentInsert'

				INSERT INTO #tblMessage (
					UserId
					,MessageContent
					,MessageTypeId
					,MinorBettypeId
					,EventDateTime
					)
				SELECT asm.UserId
					,REPLACE(CASE 
							WHEN asm.AssignmentNote IS NULL THEN @MessageInsertAssignment
							ELSE REPLACE(@MessageInsertOtherAssignment, '<note>', RTRIM(LTRIM(REPLACE(asm.AssignmentNote, '#<user>', ''))))
							END, '<event>', @MatchName + ' - bettype: ' + asm.BettypeName)
					,CASE 
						WHEN asm.AssignmentNote IS NULL THEN @MessageInsertAssignmentId
						ELSE @MessageInsertOtherAssignmentId
						END
					,asm.MinorBettypeId
					,@EventDateTime
				FROM (
					SELECT a.UserId
						,mibt.MinorBettypeName AS BettypeName
						,a.AssignmentNote
						,minor.MinorBettypeId
					FROM dbo.Assignment AS a WITH (NOLOCK)
						INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON a.OWPMatchId = minor.MinorMatchId
						INNER JOIN dbo.MinorBettype AS mibt WITH (NOLOCK) ON minor.MinorBettypeId = mibt.ParentBettypeId
						AND a.Bettype = mibt.InheritedBettypeId
					WHERE minor.ParentMatchId = @OWPMatchId
						AND minor.MinorBettypeId IN (@Specific10Mins, @Specific15Mins, @FastMarket, @AllInOne)
					
					UNION
					SELECT a.UserId
						,bt.ShortName AS BettypeName
						,a.AssignmentNote
						,NULL AS MinorBettypeId
					FROM dbo.Assignment AS a WITH (NOLOCK)
						INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON a.OWPMatchId = m.OWPMatchId
						INNER JOIN dbo.MajorBettype AS bt WITH (NOLOCK) ON a.Bettype = bt.BettypeId
					WHERE m.OWPMatchId = @OWPMatchId
					) AS asm
					LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotifyMyAssignmentUpdatedId
					LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
					AND nsm.UserId = asm.UserId
				WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'

				MERGE dbo.[Message] AS ms
				USING (
					SELECT m.UserId
						,m.MessageContent
						,m.MessageTypeId
					FROM #tblMessage AS m
					WHERE (
							m.MinorBettypeId IS NULL
							AND m.EventDateTime >= @FromTimeSendMessage
							AND m.EventDateTime <= @ToTimeSendMessage
							)
						OR (
							m.MinorBettypeId IS NOT NULL
							AND 1 = (CASE 
								WHEN EXISTS (
										SELECT 1
										FROM #tblCornerBookingBetTypes
										WHERE MinorBettypeId = m.MinorBettypeId
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
							,@UserId
							,1
							,msn.MessageTypeId
							)
				OUTPUT inserted.MessageId
					,msn.UserId
					,@SessionId
				INTO dbo.MessageUser(MessageId, UserId, SessionId);
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

				SELECT @MessageMatchStatus = mt.MsgTemplateContent
					,@MessageMatchStatusId = mt.MsgTemplateId
				FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
				WHERE mt.MsgTemplateCode = 'MatchStatus'

				SELECT @MessageMinorMatchStatus = mt.MsgTemplateContent
					,@MessageMinorMatchStatusId = mt.MsgTemplateId
				FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
				WHERE mt.MsgTemplateCode = 'MinorMatchStatus'

				-- get all assignee in match (include main + minor)
				INSERT INTO #tblAllAssigneeOfMatch (UserId)
				SELECT a.UserId
				FROM dbo.fnc_GetAllAssigneeOfMatch(@OWPMatchId) AS a

				-- get list users received ASSIGNEE message update Match Info
				INSERT INTO @UserReceivedAssigneeMessageMatchInfo (Id)
				SELECT a.UserId
				FROM #tblAllAssigneeOfMatch AS a
					LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotifyAssigneeMatchInfoUpdatedId
					LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
					AND nsm.UserId = a.UserId
				WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'

				-- get all SectionMemberOfUserReceivedWatcher
				INSERT INTO #tblSectionMemberOfUserReceivedWatcher (
					MemberId
					,UserReceivedWatcherId
					)
				SELECT ISNULL(mem.UserId, r.UserId)
					,r.UserId
				FROM (
					SELECT w.UserId
						,u.SectionId
					FROM dbo.fnc_GetWatcherToSendMessage(@NotifyWatcherMatchInfoUpdatedId) AS w
						LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON w.UserId = u.UserId
					) AS r
					LEFT JOIN dbo.[User] AS mem WITH (NOLOCK) ON r.SectionId = mem.SectionId
					AND mem.SectionId IS NOT NULL

				-- get list users received Watcher message update Recommend Odds
				INSERT INTO @UserReceivedWatcherMessageMatchInfo (Id)
				SELECT DISTINCT sm.UserReceivedWatcherId
				FROM #tblAllAssigneeOfMatch AS a
					INNER JOIN #tblSectionMemberOfUserReceivedWatcher AS sm ON sm.MemberId = a.UserId
				WHERE NOT EXISTS (
						-- ignore user received Assignee message
						SELECT 1
						FROM @UserReceivedAssigneeMessageMatchInfo AS ur
						WHERE ur.Id = sm.UserReceivedWatcherId
						)

				-- Get message content
				INSERT INTO #tbChangeMatchStatusMessage (
					OWPMatchId
					,MinorBettypeId
					,MessageContent
					,MessageTypeId
					)
				SELECT asm.OWPMatchId
					,asm.MinorBettypeId
					,REPLACE(REPLACE(REPLACE(CASE 
									WHEN asm.MinorBettypeId IS NULL THEN @MessageMatchStatus
									ELSE @MessageMinorMatchStatus
									END, '<event>', @MatchName), '<bettype>', ISNULL(asm.BettypeName, '')), '<status>', info.MatchStatus)
					,(CASE 
						WHEN asm.MinorBettypeId IS NULL THEN @MessageMatchStatusId
						ELSE @MessageMinorMatchStatusId END
						)
				FROM (
					SELECT DISTINCT minor.MinorMatchId AS OWPMatchId --Minor match
						,mibt.MinorBettypeName AS BettypeName
						,minor.MinorBettypeId
						,@EventDateTime AS EventDateTime
					FROM dbo.MinorMatch AS minor WITH (NOLOCK)
						INNER JOIN dbo.MinorBettype AS mibt WITH (NOLOCK) ON minor.MinorBettypeId = mibt.MinorBettypeId
					WHERE minor.ParentMatchId = @OWPMatchId
						AND minor.MinorBettypeId NOT IN (@Specific15Mins, @Specific10Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
					
					UNION
					SELECT DISTINCT pmm.MinorMatchId AS OWPMatchId --Minor match @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking
						,mibt.MinorBettypeName AS BettypeName
						,pmm.MinorBettypeId
						,@EventDateTime AS EventDateTime
					FROM dbo.MinorMatch AS minor WITH (NOLOCK)
						LEFT JOIN dbo.MinorMatch AS pmm WITH (NOLOCK) ON pmm.ParentMatchId = @OWPMatchId
						AND pmm.MinorBettypeId = (CASE 
							WHEN minor.MinorBettypeId = @Specific15MinsNoOfCorners THEN @NoOfCorners
							ELSE @TotalBooking END
							)
						INNER JOIN dbo.MinorBettype AS mibt WITH (NOLOCK) ON mibt.MinorBettypeId = pmm.MinorBettypeId
					WHERE minor.ParentMatchId = @OWPMatchId
						AND minor.MinorBettypeId IN (@Specific15MinsNoOfCorners, @Specific15MinsTotalBooking)
					
					UNION -- Parent match
					SELECT @OWPMatchId
						,NULL AS BettypeName
						,NULL AS MinorBettypeId
						,@EventDateTime AS EventDateTime
					
					UNION -- Match 15mis 10mins FM AIO
					SELECT DISTINCT minor.MinorMatchId AS OWPMatchId
						,NULL AS BettypeName
						,NULL AS MinorBettypeId
						,@EventDateTime AS EventDateTime
					FROM dbo.MinorMatch AS minor WITH (NOLOCK)
					WHERE minor.ParentMatchId = @OWPMatchId
						AND minor.MinorBettypeId IN (@Specific15Mins, @Specific10Mins, @FastMarket, @AllInOne)
					) AS asm
					INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON asm.OWPMatchId = info.OWPMatchId
					LEFT JOIN #tblOldMatchInfo AS oldinfo ON asm.OWPMatchId = oldinfo.OWPMatchId
				WHERE info.MatchStatus <> oldinfo.MatchStatus -- NOTE: (to send message to match has diff status)
					AND (
						(
							asm.MinorBettypeId IS NULL
							AND asm.EventDateTime >= @FromTimeSendMessage
							AND asm.EventDateTime <= @ToTimeSendMessage
							)
						OR (
							asm.MinorBettypeId IS NOT NULL
							AND 1 = (CASE 
								WHEN EXISTS (
										SELECT 1
										FROM #tblCornerBookingBetTypes
										WHERE MinorBettypeId = asm.MinorBettypeId
										) THEN CASE 
										WHEN asm.EventDateTime >= @FromTimeSendMessageSpecialBettype
											AND asm.EventDateTime <= @ToTimeSendMessageSpecialBettype THEN 1
										ELSE 0
										END
								ELSE CASE 
										WHEN asm.EventDateTime >= @FromTimeSendMessage
											AND asm.EventDateTime <= @ToTimeSendMessage THEN 1
										ELSE 0
										END END
								)
							)
						)

				DECLARE @TotalMessage INT
					,@LoopId INT = 1
					,@MessageContent NVARCHAR(2000)
					,@MessageTypeId INT

				SELECT @TotalMessage = COUNT(1)
				FROM #tbChangeMatchStatusMessage

				WHILE @LoopId <= @TotalMessage
				BEGIN
					SELECT @MessageTypeId = MessageTypeId
						,@MessageContent = MessageContent
					FROM #tbChangeMatchStatusMessage
					WHERE Id = @LoopId

					EXECUTE dbo.OWP_MessageInsert @UserId = @UserId
						,@MessageContent = @MessageContent
						,@MessageType = @MessageTypeId
						,@MessageTo = @UserReceivedAssigneeMessageMatchInfo
						,@IsImportant = 0
						,@IsWatcher = 0
						,@SessionId = @SessionId
						,@ErrCode = @ErrCode OUTPUT
						,@ErrMsg = @ErrMsg OUTPUT

					EXECUTE dbo.OWP_MessageInsert @UserId = @UserId
						,@MessageContent = @MessageContent
						,@MessageType = @MessageTypeId
						,@MessageTo = @UserReceivedWatcherMessageMatchInfo
						,@IsImportant = 0
						,@IsWatcher = 1
						,@SessionId = @SessionId
						,@ErrCode = @ErrCode OUTPUT
						,@ErrMsg = @ErrMsg OUTPUT

					SET @LoopId = @LoopId + 1
				END
			END
		END
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Update Match Status failed!'
			,@ErrCode = 1

		RETURN
	END CATCH

	DROP TABLE #tblMessage

	DROP TABLE #tblOldMatchInfo

	DROP TABLE #tblCornerBookingBetTypes

	DROP TABLE #tbChangeMatchStatusMessage

	DROP TABLE #tblAllAssigneeOfMatch

	DROP TABLE #tblSectionMemberOfUserReceivedWatcher
END