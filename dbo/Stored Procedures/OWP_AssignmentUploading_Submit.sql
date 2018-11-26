
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AssignmentUploading_Submit] @UserId INT = 0
	,@SessionId VARCHAR(50)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
 Created: 20170307@Quinn.Vo
 Task : Insert new Assignment Uploading
 DB: bodb_OWP
            
 Revisions:
	20170404@Alvin.Nguyen: insert SessionId into dbo.MessageUser
	20170725@Tim.Trinh: add IsCanceled, Remark, Round, Division, No.HDP, MatchOffer
	20171012@Tim.Trinh: add OtherTime, Website, Website2, Website3, Website4 column
	20180417@leo.vo: add FM, AIO
	20180614@Leo: change datatype of column Round & OutSide to nvarchar(2000)
	20180723@Raymond.Le: Fix send notification match cancel/postponed/suspended
	20181002@Raymond.Le: Fix overflow data type in RefResource
	20180621@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20181016@Raymond.Le: Notify assignee follow Notification Setting - [Redmine: #102867] 
	20181031@Raymond.Le: Replace column MatchId by InfoSiteMatchId - [Redmine: #104052]
*/
BEGIN
	SET NOCOUNT ON

	-- verify validation is passed before submitting
	IF EXISTS (
			SELECT 1
			FROM dbo.AssignmentUploadingLog WITH (NOLOCK)
			WHERE SessionId = @SessionId
				AND [Status] <> 3
			)
	BEGIN
		SELECT @ErrCode = 1
			,@ErrMsg = 'Validation must be passed before submitting'

		RETURN
	END

	-- update log status to inform that Submit is started
	UPDATE dbo.AssignmentUploadingLog WITH (ROWLOCK)
	SET [Status] = 4 -- submit
		,StartDate = GETDATE()
	WHERE SessionId = @SessionId
		AND [Status] = 3 -- Validated

	DECLARE @EventDate DATE
		,@EventFromDateTime DATETIME
		,@EventToDateTime DATETIME
		-- Message
		,@MessageInsertAssignment NVARCHAR(2000)
		,@MessageInsertAssignmentId INT
		,@MessageDeleteAssignment NVARCHAR(2000)
		,@MessageDeleteAssignmentId INT
		,@MessageMatchStatus NVARCHAR(2000)
		,@MessageMatchStatusId INT
		,@MessageMinorMatchStatus NVARCHAR(2000)
		,@MessageMinorMatchStatusId INT
		,@MessageInsertOtherAssignment NVARCHAR(2000)
		,@MessageInsertOtherAssignmentId INT
		,@MessageDeleteOtherAssignment NVARCHAR(2000)
		,@MessageDeleteOtherAssignmentId INT
		,@MessageChangeOfAssignment NVARCHAR(2000)
		,@MessageChangeOfAssignmentId INT
		-- send message by condition date
		,@FromTimeSendMessage DATETIME
		,@ToTimeSendMessage DATETIME
		,@FromTimeSendMessageSpecialBettype DATETIME
		,@ToTimeSendMessageSpecialBettype DATETIME
		,@NextCornerId INT = - 4
		,@NextBookingId INT = - 7
		,@NoOfCorners INT = - 3
		,@TotalBooking INT = - 6
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@Specific15MinsNoOfCorners INT = - 5
		,@Specific15MinsTotalBooking INT = - 8
		,@FastMarket INT = - 88
		,@AllInOne INT = - 89
		-- Match Status
		,@str_Live NVARCHAR(15) = 'Live'
		,@str_Cancel NVARCHAR(15) = 'Cancel'
		,@str_Postponed NVARCHAR(15) = 'Postponed'
		,@str_Suspended NVARCHAR(15) = 'Suspended'
		,@CurrentDateTimeGMTplus8 DATETIME = DATEADD(HOUR, 12, GETDATE())
		,@Username VARCHAR(30)

	SELECT @Username = dbo.fnc_GetUsernameByUserId(@UserId)

	--Get event upload date
	SELECT TOP 1 @EventDate = CASE 
			WHEN CAST(KickOffTime AS TIME) >= CAST('12:00:00' AS TIME) THEN EventDate
			ELSE DATEADD(DD, - 1, EventDate)
			END
	FROM dbo.AssignmentUploading WITH (NOLOCK)
	WHERE SessionId = @SessionId

	SET @EventFromDateTime = DATEADD(HOUR, 12, CAST(@EventDate AS DATETIME))
	SET @EventToDateTime = DATEADD(DAY, 1, @EventFromDateTime)

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

	--upload data
	CREATE TABLE #tblMatch (
		RowNumber INT
		,ParentRowNumber INT
		,MinorBetTypeId INT
		,OWPMatchId INT
		,EventDate DATETIME
		,League NVARCHAR(2000)
		,OWPLeagueId INT
		,Home NVARCHAR(2000)
		,OWPHomeId INT
		,Away NVARCHAR(2000)
		,OWPAwayId INT
		,MatchNo VARCHAR(50)
		,KickOffTime TIME(7)
		,OtherTime TIME(7)
		,TV NVARCHAR(2000)
		,Channel NVARCHAR(100)
		,WB NVARCHAR(100)
		,Agent NVARCHAR(2000)
		,[Provider] NVARCHAR(2000)
		,Runner NVARCHAR(2000)
		,Phone NVARCHAR(50)
		,Note XML
		,MaxBetHDP MONEY
		,SpreadHDP SMALLMONEY
		,MaxBet1HHDP MONEY
		,Spread1HHDP SMALLMONEY
		,MaxBetOU MONEY
		,SpreadOU SMALLMONEY
		,MaxBet1HOU MONEY
		,Spread1HOU SMALLMONEY
		,MaxBet1X2 MONEY
		,Spread1X2 SMALLMONEY
		,MaxBet1H1X2 MONEY
		,Spread1H1X2 SMALLMONEY
		,TraderHDP NVARCHAR(200)
		,Trader1HHDP NVARCHAR(200)
		,TraderOU NVARCHAR(200)
		,Trader1HOU NVARCHAR(200)
		,Trader1X2 NVARCHAR(200)
		,Trader1H1X2 NVARCHAR(200)
		,LA NVARCHAR(200)
		,MaxBetXMins MONEY
		,SpreadXMins SMALLMONEY
		,MaxBetFM MONEY
		,SpreadFM SMALLMONEY
		,EventDateTime DATETIME
		,MatchStatus VARCHAR(15)
		,[Round] NVARCHAR(2000)
		,Division NVARCHAR(2000)
		,Remark NVARCHAR(2000)
		,NoOfHDP NVARCHAR(20)
		,MatchOffer NVARCHAR(50)
		,Website1 NVARCHAR(1000)
		,Website2 NVARCHAR(1000)
		,Website3 NVARCHAR(1000)
		,Website4 NVARCHAR(1000)
		,InfoSiteMatchId INT
		)

	--list of existed matches
	CREATE TABLE #tblExistedMatch (
		RowNumber INT NOT NULL
		,OWPMatchId INT NOT NULL
		)

	--list of matches will be inserted
	CREATE TABLE #tblNewMatch (
		RowNumber INT NOT NULL
		,OWPMatchId INT NOT NULL
		)

	--list of matches will be removed
	CREATE TABLE #tblRemoveMatch (OWPMatchId INT NOT NULL)

	--list of minor matches generated from upload data
	CREATE TABLE #tblMinorMatch (
		MinorMatchId INT
		,ParentMatchId INT
		,MinorBetTypeId INT
		)

	--log for actions on table MinorMatch
	CREATE TABLE #tblMinorMatchLog (
		[Action] VARCHAR(10) NOT NULL
		,MinorMatchId INT
		,ParentMatchId INT
		,MinorBetTypeId INT
		)

	--log for actions on table OWPTeam
	CREATE TABLE #tblTeamLog (
		[Action] VARCHAR(10) NOT NULL
		,OWPTeamId INT NOT NULL
		,OWPTeamName NVARCHAR(200) NOT NULL
		)

	--log for actions on table OWPLeague
	CREATE TABLE #tblLeagueLog (
		[Action] VARCHAR(10) NOT NULL
		,OWPLeagueId INT NOT NULL
		,CategoryId SMALLINT
		,OWPLeagueName NVARCHAR(2000) NOT NULL
		)

	--list of upload values of TV, Runner, Provider or Agent in upload data
	CREATE TABLE #tblTextList (
		OWPMatchId INT NOT NULL
		,[Text] NVARCHAR(100) NOT NULL
		,OrderId INT IDENTITY(1, 1)
		)

	CREATE TABLE #tblDistinctTextList (
		OWPMatchId INT NOT NULL
		,Id INT
		,[Text] NVARCHAR(100) NOT NULL
		)

	CREATE TABLE #tblOldDistinctTextList (
		OWPMatchId INT NOT NULL
		,Id INT
		,[Text] NVARCHAR(100) NOT NULL
		)

	CREATE TABLE #tblMatchEditedInfo (
		OWPMatchId INT NOT NULL
		,MessageTemplateCode NVARCHAR(50)
		,OldValue NVARCHAR(500)
		,NewValue NVARCHAR(500)
		)

	-- store all match (main + minor) edited match info in TimeRange
	CREATE TABLE #tblMatchEditedInTimeRange (
		OWPMatchId INT NOT NULL
		,MessageTemplateCode NVARCHAR(50)
		,OldValue NVARCHAR(500)
		,NewValue NVARCHAR(500)
		,ParentMatchId INT
		)

	-- store all match (main + minor) in TimeRange
	CREATE TABLE #tblMatchInTimeRange (
		OWPMatchId INT NOT NULL
		,ParentMatchId INT
		)

	CREATE TABLE #tblUsersReceivedMessageUpdateMatchInfo (
		OWPMatchId INT NOT NULL
		,MessageTemplateCode NVARCHAR(50)
		,UserId INT
		)

	CREATE TABLE #tblInsertedMessageUpdateMatchInfo (
		OWPMatchId INT NOT NULL
		,MessageTemplateCode NVARCHAR(50)
		,MessageId INT
		)

	--save of MatchInfo of existed matches, used to send message if MatchStatus changed
	CREATE TABLE #tblOldMatchInfo (
		OWPMatchId INT NOT NULL
		,MatchStatus VARCHAR(15)
		,TVCode NVARCHAR(500)
		,Channel NVARCHAR(100)
		,WB NVARCHAR(100)
		,Provider NVARCHAR(100)
		,Runner NVARCHAR(100) --OtherProvider
		,Phone NVARCHAR(50)
		,KOTimeRemark NVARCHAR(50) --MatchOffer
		,[Round] NVARCHAR(2000)
		,Division NVARCHAR(2000)
		,Venue NVARCHAR(100)
		,Agent NVARCHAR(100)
		,Remark NVARCHAR(2000)
		,NoOfHDP NVARCHAR(20)
		)

	CREATE TABLE #tblOldOWPMatch (
		OWPMatchId INT NOT NULL
		,OtherTime TIME(7)
		)

	--list of upload note
	CREATE TABLE #tblMatchNote (
		OWPMatchId INT NOT NULL
		,CreatedBy INT NOT NULL
		,Note NVARCHAR(4000) NOT NULL
		)

	--log for actions on table MatchNote
	CREATE TABLE #tblMatchNoteLog (
		[Action] VARCHAR(10)
		,MatchNoteId INT NOT NULL
		,OWPMatchId INT NOT NULL
		,CreatedBy INT NOT NULL
		,Note NVARCHAR(4000)
		)

	--list of MatchSetting from upload data
	CREATE TABLE #tblMatchSetting (
		OWPMatchId INT NOT NULL
		,BetType INT NOT NULL
		,MaxBet MONEY
		,Spread SMALLMONEY
		)

	--log for actions on table MatchSetting
	CREATE TABLE #tblMatchSettingLog (
		[Action] VARCHAR(10)
		,OWPMatchId INT NOT NULL
		,BetType INT NOT NULL
		,MaxBet MONEY
		,Spread SMALLMONEY
		)

	--list of Assignment from upload data
	CREATE TABLE #tblAssignment (
		OWPMatchId INT NOT NULL
		,BetType INT NOT NULL
		,AssignmentType INT NOT NULL
		,UserId INT
		,AssignmentNote NVARCHAR(200)
		)

	--log for actions on table Assignment for current upload session
	CREATE TABLE #tblAssignmentLog (
		[Action] VARCHAR(10) -- value is DELETE or INSERT or UPDATE
		,OWPMatchId INT NOT NULL
		,BetType INT NOT NULL
		,AssignmentType INT NOT NULL
		,UserId INT
		,Username NVARCHAR(30)
		,AssignmentNote NVARCHAR(200)
		,OldUserId INT
		,OldUsername NVARCHAR(30)
		,OldAssignmentNote NVARCHAR(200)
		)

	CREATE TABLE #tblAssignmentInTimeRange (
		[Action] VARCHAR(10) -- value is DELETE or INSERT or UPDATE
		,OWPMatchId INT NOT NULL
		,ParentMatchId INT
		,BetType INT NOT NULL
		,AssignmentType INT NOT NULL
		,UserId INT
		,Username NVARCHAR(30)
		,AssignmentNote NVARCHAR(200)
		,OldUserId INT
		,OldUsername NVARCHAR(30)
		,OldAssignmentNote NVARCHAR(200)
		,EventName NVARCHAR(2000)
		)

	--list of old other Assignment of uploaded matches (will be removed)
	CREATE TABLE #tblOldOtherAssignment (
		OWPMatchId INT NOT NULL
		,BetType INT NOT NULL
		,UserId INT
		,AssignmentNote NVARCHAR(200)
		)

	-- list of message for change of assignment. UserId is related to change of assignment or can be NULL if assignment is other with note only
	CREATE TABLE #tblChangeOfAssignmentMessage (
		OWPMatchId INT NOT NULL
		,ParentMatchId INT NOT NULL
		,UserId INT
		,MessageContent NVARCHAR(2000)
		)

	--list of messages will be sent
	CREATE TABLE #tblAssignmentMessage (
		UserId INT NOT NULL
		,MessageContent NVARCHAR(MAX) NOT NULL
		,MessageTypeId INT NOT NULL
		,NotificationSettingId INT NOT NULL
		,IsImportant BIT NOT NULL
		)

	CREATE TABLE #tblMessage (
		UserId INT NOT NULL
		,MessageContent NVARCHAR(MAX) NOT NULL
		,MessageTypeId INT NOT NULL
		,IsImportant BIT NOT NULL
		)

	BEGIN TRY
		-- fill AssignmentUploading data to temp table with right datatype
		INSERT INTO #tblMatch (
			RowNumber
			,ParentRowNumber
			,MinorBetTypeId
			,OWPMatchId
			,EventDate
			,League
			,Home
			,Away
			,MatchNo
			,KickOffTime
			,OtherTime
			,TV
			,Channel
			,WB
			,Agent
			,[Provider]
			,Runner
			,Phone
			,Note
			,MaxBetHDP
			,SpreadHDP
			,MaxBet1HHDP
			,Spread1HHDP
			,MaxBetOU
			,SpreadOU
			,MaxBet1HOU
			,Spread1HOU
			,MaxBet1X2
			,Spread1X2
			,MaxBet1H1X2
			,Spread1H1X2
			,TraderHDP
			,Trader1HHDP
			,TraderOU
			,Trader1HOU
			,Trader1X2
			,Trader1H1X2
			,LA
			,MaxBetXMins
			,SpreadXMins
			,MaxBetFM
			,SpreadFM
			,EventDateTime
			,MatchStatus
			,[Round]
			,Division
			,Remark
			,NoOfHDP
			,MatchOffer
			,Website1
			,Website2
			,Website3
			,Website4
			,InfoSiteMatchId
			)
		SELECT au.RowNumber
			,au.ParentRowNumber
			,au.MinorBettypeId
			,NULL
			,au.EventDate
			,au.League
			,au.Home
			,au.Away
			,ISNULL(au.MatchNo, '')
			,au.KickOffTime
			,CASE 
				WHEN ISNULL(au.OtherTime, '') <> '' THEN au.OtherTime
				ELSE NULL
				END
			,ISNULL(au.TV, '')
			,ISNULL(au.Channel, '')
			,ISNULL(au.WB, '')
			,ISNULL(au.Agent, '')
			,ISNULL(au.[Provider], '')
			,ISNULL(au.Runner, '')
			,ISNULL(au.Phone, '')
			,au.Note
			,CASE 
				WHEN ISNUMERIC(au.MaxBetHDP) = 1 THEN CAST(au.MaxBetHDP AS MONEY)
				ELSE NULL
				END
			,CASE 
				WHEN ISNUMERIC(au.SpreadHDP) = 1 THEN CAST(au.SpreadHDP AS SMALLMONEY)
				ELSE NULL
				END
			,CASE 
				WHEN ISNUMERIC(au.MaxBet1HHDP) = 1 THEN CAST(au.MaxBet1HHDP AS MONEY)
				ELSE NULL
				END
			,CASE 
				WHEN ISNUMERIC(au.Spread1HHDP) = 1 THEN CAST(au.Spread1HHDP AS SMALLMONEY)
				ELSE NULL
				END
			,CASE 
				WHEN ISNUMERIC(au.MaxBetOU) = 1 THEN CAST(au.MaxBetOU AS MONEY)
				ELSE NULL
				END
			,CASE 
				WHEN ISNUMERIC(au.SpreadOU) = 1 THEN CAST(au.SpreadOU AS SMALLMONEY)
				ELSE NULL
				END
			,CASE 
				WHEN ISNUMERIC(au.MaxBet1HOU) = 1 THEN CAST(au.MaxBet1HOU AS MONEY)
				ELSE NULL
				END
			,CASE 
				WHEN ISNUMERIC(au.Spread1HOU) = 1 THEN CAST(au.Spread1HOU AS SMALLMONEY)
				ELSE NULL
				END
			,CASE 
				WHEN ISNUMERIC(au.MaxBet1X2) = 1 THEN CAST(au.MaxBet1X2 AS MONEY)
				ELSE NULL
				END
			,CASE 
				WHEN ISNUMERIC(au.Spread1X2) = 1 THEN CAST(au.Spread1X2 AS SMALLMONEY)
				ELSE NULL
				END
			,CASE 
				WHEN ISNUMERIC(au.MaxBet1H1X2) = 1 THEN CAST(au.MaxBet1H1X2 AS MONEY)
				ELSE NULL
				END
			,CASE 
				WHEN ISNUMERIC(au.Spread1H1X2) = 1 THEN CAST(au.Spread1H1X2 AS SMALLMONEY)
				ELSE NULL
				END
			,au.TraderHDP
			,au.Trader1HHDP
			,au.TraderOU
			,au.Trader1HOU
			,au.Trader1X2
			,au.Trader1H1X2
			,au.LA
			,CASE 
				WHEN ISNUMERIC(au.MaxBetXMins) = 1 THEN CAST(au.MaxBetXMins AS MONEY)
				ELSE NULL
				END
			,CASE 
				WHEN ISNUMERIC(au.SpreadXMins) = 1 THEN CAST(au.SpreadXMins AS SMALLMONEY)
				ELSE NULL
				END
			,CASE 
				WHEN ISNUMERIC(au.MaxBetFM) = 1 THEN CAST(au.MaxBetFM AS MONEY)
				ELSE NULL
				END
			,CASE 
				WHEN ISNUMERIC(au.SpreadFM) = 1 THEN CAST(au.SpreadFM AS SMALLMONEY)
				ELSE NULL
				END
			,DATEADD(DAY, DATEDIFF(DAY, 0, EventDate), CAST(KickOffTime AS DATETIME))
			,au.MatchStatus
			,au.[Round]
			,au.Division
			,au.Remark
			,au.NoHDP
			,au.MatchOffer
			,au.Website1
			,au.Website2
			,au.Website3
			,au.Website4
			,CASE 
				WHEN ISNUMERIC(au.InfoSiteMatchId) = 1 AND CAST(au.InfoSiteMatchId AS BIGINT) <= 2147483647 THEN au.InfoSiteMatchId
				ELSE NULL
				END -- Should run VALIDATION InfoSiteMatchId before insert into table OWPMatch
		FROM dbo.AssignmentUploading AS au WITH (NOLOCK)
		WHERE SessionId = @SessionId

		-- Insert Home & Away Team
		INSERT INTO dbo.OWPTeam (OWPTeamName)
		OUTPUT 'DELETE'
			,inserted.OWPTeamId
			,inserted.OWPTeamName
		INTO #tblTeamLog([Action], OWPTeamId, OWPTeamName)
		SELECT t.TeamName
		FROM (
			SELECT Home AS TeamName
			FROM #tblMatch
			
			UNION -- distinct & sort default
			SELECT Away AS TeamName
			FROM #tblMatch
			) AS t
		WHERE NOT EXISTS (
				SELECT 1
				FROM dbo.OWPTeam WITH (NOLOCK)
				WHERE OWPTeamName = t.TeamName
				)

		-- Insert League
		INSERT INTO dbo.OWPLeague (OWPLeagueName)
		OUTPUT 'DELETE'
			,inserted.OWPLeagueId
			,inserted.CategoryId
			,inserted.OWPLeagueName
		INTO #tblLeagueLog([Action], OWPLeagueId, CategoryId, OWPLeagueName)
		SELECT DISTINCT m.League
		FROM #tblMatch AS m
		WHERE NOT EXISTS (
				SELECT 1
				FROM dbo.OWPLeague AS ol WITH (NOLOCK)
				WHERE ol.OWPLeagueName = m.League
				)

		-- update OWPLeagueId, OWPHomeId, OWPAwayId
		UPDATE m
		SET m.OWPLeagueId = l.OWPLeagueId
			,m.OWPHomeId = h.OWPTeamId
			,m.OWPAwayId = a.OWPTeamId
		FROM #tblMatch AS m
			INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON m.League = l.OWPLeagueName
			INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.Home = h.OWPTeamName
			INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.Away = a.OWPTeamName

		-- Update OWPMatchId of matches have same League, Home, Away, EventDate & same Upload time
		UPDATE m
		SET m.OWPMatchId = om.OWPMatchId
		FROM #tblMatch AS m
			INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON m.OWPLeagueId = om.OWPLeagueId
			AND m.OWPHomeId = om.OWPHomeId
			AND m.OWPAwayId = om.OWPAwayId
			AND om.EventDateTime >= @EventFromDateTime
			AND om.EventDateTime < @EventToDateTime
			LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON mm.MinorMatchId = om.OWPMatchId
		WHERE m.OWPMatchId IS NULL
			AND (
				(
					m.ParentRowNumber IS NOT NULL
					AND mm.MinorMatchId IS NOT NULL
					)
				OR (
					m.ParentRowNumber IS NULL
					AND mm.MinorMatchId IS NULL
					)
				)

		-- Save old OWPMatch (OtherTime) to send message
		INSERT INTO #tblOldOWPMatch (
			OWPMatchId
			,OtherTime
			)
		SELECT m.OWPMatchId
			,om.OtherTime
		FROM dbo.OWPMatch AS om WITH (ROWLOCK)
			INNER JOIN #tblMatch AS m ON m.OWPMatchId = om.OWPMatchId
		WHERE m.OWPMatchId IS NOT NULL

		-- Update MatchNo, OtherTime, EventDate, EventDateTime, KickOffTime of existed matches
		UPDATE om
		SET om.MatchNo = m.MatchNo
			,om.OtherTime = m.OtherTime
			,om.EventDate = m.EventDate
			,om.KickOffTime = m.KickOffTime
			,om.EventDateTime = m.EventDateTime
			,om.InfoSiteMatchId = m.InfoSiteMatchId
		OUTPUT m.RowNumber
			,m.OWPMatchId
		INTO #tblExistedMatch(RowNumber, OWPMatchId)
		FROM dbo.OWPMatch AS om WITH (ROWLOCK)
			INNER JOIN #tblMatch AS m ON m.OWPMatchId = om.OWPMatchId
		WHERE m.OWPMatchId IS NOT NULL

		-- Insert new matches
		MERGE INTO dbo.OWPMatch WITH (ROWLOCK) AS om
		USING (
			SELECT m.RowNumber
				,m.MatchNo
				,m.EventDate
				,m.KickOffTime
				,m.OWPLeagueId
				,m.OWPHomeId
				,m.OWPAwayId
				,m.OtherTime
				,m.EventDateTime
				,m.InfoSiteMatchId
			FROM #tblMatch AS m
			WHERE m.OWPMatchId IS NULL
			) AS mat ON 1 = 0 --https://stackoverflow.com/questions/37692711/tsql-the-multi-part-identifier-b-id-could-not-be-bound-using-insert-output-se
		WHEN NOT MATCHED THEN
				INSERT (
					MatchNo
					,EventDate
					,KickOffTime
					,OWPLeagueId
					,OWPHomeId
					,OWPAwayId
					,OtherTime
					,EventDateTime
					,InfoSiteMatchId
					)
				VALUES (
					mat.MatchNo
					,mat.EventDate
					,mat.KickOffTime
					,mat.OWPLeagueId
					,mat.OWPHomeId
					,mat.OWPAwayId
					,mat.OtherTime
					,mat.EventDateTime
					,mat.InfoSiteMatchId
					)
		OUTPUT mat.RowNumber
			,inserted.OWPMatchId
		INTO #tblNewMatch(RowNumber, OWPMatchId);

		--Update #tblMatch to make all rows has valid OWPMatchId
		UPDATE m
		SET m.OWPMatchId = nm.OWPMatchId
		FROM #tblMatch AS m
			INNER JOIN #tblNewMatch AS nm ON nm.RowNumber = m.RowNumber

		-- Get list of match same upload time but not in upload file
		INSERT INTO #tblRemoveMatch (OWPMatchId)
		SELECT mat.OWPMatchId
		FROM dbo.OWPMatch AS mat WITH (NOLOCK)
		WHERE mat.EventDateTime >= @EventFromDateTime
			AND mat.EventDateTime < @EventToDateTime
			AND NOT EXISTS (
				SELECT 1
				FROM #tblMatch AS m
				WHERE m.OWPMatchId = mat.OWPMatchId
				)

		--Set MatchNo empty on matches same upload time but not uploaded
		UPDATE ma
		SET ma.MatchNo = ''
		FROM dbo.OWPMatch AS ma WITH (ROWLOCK)
			INNER JOIN #tblRemoveMatch AS rm WITH (NOLOCK) ON ma.OWPMatchId = rm.OWPMatchId

		--list of old MatchInfo of existed matches
		INSERT INTO #tblOldMatchInfo (
			OWPMatchId
			,MatchStatus
			,TVCode
			,Channel
			,WB
			,Provider
			,Runner
			,Phone
			,KOTimeRemark
			,[Round]
			,Division
			,Venue
			,Agent
			,Remark
			,NoOfHDP
			)
		SELECT mi.OWPMatchId
			,mi.MatchStatus
			,mi.TVCode
			,mi.Channel
			,mi.WB
			,mi.Provider
			,mi.Runner
			,mi.Phone
			,mi.KOTimeRemark
			,mi.[Round]
			,mi.Division
			,mi.Venue
			,mi.Agent
			,mi.Remark
			,mi.NoOfHDP
		FROM dbo.MatchInfo AS mi WITH (NOLOCK)
			INNER JOIN #tblExistedMatch AS m ON m.OWPMatchId = mi.OWPMatchId

		-- Insert new TV
		DELETE
		FROM #tblTextList

		DELETE
		FROM #tblDistinctTextList

		DELETE
		FROM #tblOldDistinctTextList

		INSERT INTO #tblTextList (
			OWPMatchId
			,[Text]
			)
		SELECT m.OWPMatchId
			,CAST(RTRIM(LTRIM(d.val)) AS NVARCHAR(100))
		FROM #tblMatch AS m
			CROSS APPLY dbo.fnc_SplitStrings(REPLACE(m.TV, '/', ','), ',') AS d
		WHERE m.TV <> ''
			AND RTRIM(LTRIM(d.val)) <> ''

		INSERT INTO #tblDistinctTextList (
			OWPMatchId
			,[Text]
			)
		SELECT OWPMatchId
			,[Text]
		FROM #tblTextList
		GROUP BY OWPMatchId
			,[Text]
		ORDER BY MIN(OrderId) ASC

		INSERT INTO dbo.Television (TVCode)
		SELECT DISTINCT tl.[Text]
		FROM #tblDistinctTextList AS tl
		WHERE NOT EXISTS (
				SELECT 1
				FROM dbo.Television WITH (NOLOCK)
				WHERE TVCode = tl.[Text]
				)

		UPDATE tl
		SET tl.Id = tv.TVId
		FROM #tblDistinctTextList AS tl
			INNER JOIN dbo.Television AS tv WITH (NOLOCK) ON tl.[Text] = tv.TVCode

		UPDATE m
		SET m.TV = STUFF((
					SELECT ',' + CAST(Id AS VARCHAR(10))
					FROM #tblDistinctTextList AS tl
					WHERE tl.OWPMatchId = m.OWPMatchId
					FOR XML PATH('')
					), 1, 1, '')
		FROM #tblMatch AS m
		WHERE m.TV <> ''

		-- get matches edited TV
		INSERT INTO #tblOldDistinctTextList (
			OWPMatchId
			,Id
			,[Text]
			)
		SELECT em.OWPMatchId
			,tv.TVId
			,tv.TVCode
		FROM #tblExistedMatch AS em
			INNER JOIN #tblOldMatchInfo AS omi ON em.OWPMatchId = omi.OWPMatchId
			CROSS APPLY dbo.fnc_SplitStrings(omi.TVCode, ',') AS f
			INNER JOIN dbo.Television AS tv WITH (NOLOCK) ON f.val = tv.TVId

		INSERT INTO #tblMatchEditedInfo (
			OWPMatchId
			,OldValue
			,NewValue
			,MessageTemplateCode
			)
		SELECT em.OWPMatchId
			,ISNULL(STUFF((
						SELECT ', ' + [Text]
						FROM #tblOldDistinctTextList AS old
						WHERE old.OWPMatchId = em.OWPMatchId
						FOR XML PATH('')
						), 1, 2, ''), '')
			,ISNULL(STUFF((
						SELECT ', ' + [Text]
						FROM #tblDistinctTextList AS new
						WHERE new.OWPMatchId = em.OWPMatchId
						FOR XML PATH('')
						), 1, 2, ''), '')
			,'EditTV' AS MessageTemplateCode
		FROM #tblExistedMatch AS em
		WHERE EXISTS (
				SELECT Id
				FROM #tblOldDistinctTextList
				WHERE OWPMatchId = em.OWPMatchId
				
				EXCEPT
				SELECT Id
				FROM #tblDistinctTextList
				WHERE OWPMatchId = em.OWPMatchId
				)
			OR EXISTS (
				SELECT Id
				FROM #tblDistinctTextList
				WHERE OWPMatchId = em.OWPMatchId
				
				EXCEPT
				SELECT Id
				FROM #tblOldDistinctTextList
				WHERE OWPMatchId = em.OWPMatchId
				)

		-- Insert new Agent
		DELETE
		FROM #tblTextList

		DELETE
		FROM #tblDistinctTextList

		DELETE
		FROM #tblOldDistinctTextList

		INSERT INTO #tblTextList (
			OWPMatchId
			,[Text]
			)
		SELECT m.OWPMatchId
			,CAST(RTRIM(LTRIM(d.val)) AS NVARCHAR(100))
		FROM #tblMatch AS m
			CROSS APPLY dbo.fnc_SplitStrings(REPLACE(m.Agent, '/', ','), ',') AS d
		WHERE m.Agent <> ''
			AND RTRIM(LTRIM(d.val)) <> ''

		INSERT INTO #tblDistinctTextList (
			OWPMatchId
			,[Text]
			)
		SELECT OWPMatchId
			,[Text]
		FROM #tblTextList
		GROUP BY OWPMatchId
			,[Text]
		ORDER BY MIN(OrderId) ASC

		INSERT INTO dbo.Agent (AgentName)
		SELECT DISTINCT tl.[Text]
		FROM #tblDistinctTextList AS tl
		WHERE NOT EXISTS (
				SELECT 1
				FROM dbo.Agent WITH (NOLOCK)
				WHERE AgentName = tl.[Text]
				)

		UPDATE tl
		SET tl.Id = tv.AgentId
		FROM #tblDistinctTextList AS tl
			INNER JOIN dbo.Agent AS tv WITH (NOLOCK) ON tl.[Text] = tv.AgentName

		UPDATE m
		SET m.Agent = STUFF((
					SELECT ',' + CAST(Id AS VARCHAR(10))
					FROM #tblDistinctTextList AS tl
					WHERE tl.OWPMatchId = m.OWPMatchId
					FOR XML PATH('')
					), 1, 1, '')
		FROM #tblMatch AS m
		WHERE m.Agent <> ''

		-- get matches edited Agent
		INSERT INTO #tblOldDistinctTextList (
			OWPMatchId
			,Id
			,[Text]
			)
		SELECT em.OWPMatchId
			,agent.AgentId
			,agent.AgentName
		FROM #tblExistedMatch AS em
			INNER JOIN #tblOldMatchInfo AS omi ON em.OWPMatchId = omi.OWPMatchId
			CROSS APPLY dbo.fnc_SplitStrings(omi.Agent, ',') AS f
			INNER JOIN dbo.Agent AS agent WITH (NOLOCK) ON f.val = agent.AgentId

		INSERT INTO #tblMatchEditedInfo (
			OWPMatchId
			,OldValue
			,NewValue
			,MessageTemplateCode
			)
		SELECT em.OWPMatchId
			,ISNULL(STUFF((
						SELECT ', ' + [Text]
						FROM #tblOldDistinctTextList AS old
						WHERE old.OWPMatchId = em.OWPMatchId
						FOR XML PATH('')
						), 1, 2, ''), '')
			,ISNULL(STUFF((
						SELECT ', ' + [Text]
						FROM #tblDistinctTextList AS new
						WHERE new.OWPMatchId = em.OWPMatchId
						FOR XML PATH('')
						), 1, 2, ''), '')
			,'EditAgent' AS MessageTemplateCode
		FROM #tblExistedMatch AS em
		WHERE EXISTS (
				SELECT Id
				FROM #tblOldDistinctTextList
				WHERE OWPMatchId = em.OWPMatchId
				
				EXCEPT
				SELECT Id
				FROM #tblDistinctTextList
				WHERE OWPMatchId = em.OWPMatchId
				)
			OR EXISTS (
				SELECT Id
				FROM #tblDistinctTextList
				WHERE OWPMatchId = em.OWPMatchId
				
				EXCEPT
				SELECT Id
				FROM #tblOldDistinctTextList
				WHERE OWPMatchId = em.OWPMatchId
				)

		-- Insert new Runner
		DELETE
		FROM #tblTextList

		DELETE
		FROM #tblDistinctTextList

		DELETE
		FROM #tblOldDistinctTextList

		INSERT INTO #tblTextList (
			OWPMatchId
			,[Text]
			)
		SELECT m.OWPMatchId
			,CAST(RTRIM(LTRIM(d.val)) AS NVARCHAR(100))
		FROM #tblMatch AS m
			CROSS APPLY dbo.fnc_SplitStrings(REPLACE(m.Runner, '/', ','), ',') AS d
		WHERE m.Runner <> ''
			AND RTRIM(LTRIM(d.val)) <> ''

		INSERT INTO #tblDistinctTextList (
			OWPMatchId
			,[Text]
			)
		SELECT OWPMatchId
			,[Text]
		FROM #tblTextList
		GROUP BY OWPMatchId
			,[Text]
		ORDER BY MIN(OrderId) ASC

		INSERT INTO dbo.Runner (RunnerName)
		SELECT DISTINCT tl.[Text]
		FROM #tblDistinctTextList AS tl
		WHERE NOT EXISTS (
				SELECT 1
				FROM dbo.Runner WITH (NOLOCK)
				WHERE RunnerName = tl.[Text]
				)

		UPDATE tl
		SET tl.Id = tv.RunnerId
		FROM #tblDistinctTextList AS tl
			INNER JOIN dbo.Runner AS tv WITH (NOLOCK) ON tl.[Text] = tv.RunnerName

		UPDATE m
		SET m.Runner = STUFF((
					SELECT ',' + CAST(Id AS VARCHAR(10))
					FROM #tblDistinctTextList AS tl
					WHERE tl.OWPMatchId = m.OWPMatchId
					FOR XML PATH('')
					), 1, 1, '')
		FROM #tblMatch AS m
		WHERE m.Runner <> ''

		-- get matches edited Runner
		INSERT INTO #tblOldDistinctTextList (
			OWPMatchId
			,Id
			,[Text]
			)
		SELECT em.OWPMatchId
			,r.RunnerId
			,r.RunnerName
		FROM #tblExistedMatch AS em
			INNER JOIN #tblOldMatchInfo AS omi ON em.OWPMatchId = omi.OWPMatchId
			CROSS APPLY dbo.fnc_SplitStrings(omi.Runner, ',') AS f
			INNER JOIN dbo.Runner AS r WITH (NOLOCK) ON f.val = r.RunnerId

		INSERT INTO #tblMatchEditedInfo (
			OWPMatchId
			,OldValue
			,NewValue
			,MessageTemplateCode
			)
		SELECT em.OWPMatchId
			,ISNULL(STUFF((
						SELECT ', ' + [Text]
						FROM #tblOldDistinctTextList AS old
						WHERE old.OWPMatchId = em.OWPMatchId
						FOR XML PATH('')
						), 1, 2, ''), '')
			,ISNULL(STUFF((
						SELECT ', ' + [Text]
						FROM #tblDistinctTextList AS new
						WHERE new.OWPMatchId = em.OWPMatchId
						FOR XML PATH('')
						), 1, 2, ''), '')
			,'EditOtherProvider' AS MessageTemplateCode
		FROM #tblExistedMatch AS em
		WHERE EXISTS (
				SELECT Id
				FROM #tblOldDistinctTextList
				WHERE OWPMatchId = em.OWPMatchId
				
				EXCEPT
				SELECT Id
				FROM #tblDistinctTextList
				WHERE OWPMatchId = em.OWPMatchId
				)
			OR EXISTS (
				SELECT Id
				FROM #tblDistinctTextList
				WHERE OWPMatchId = em.OWPMatchId
				
				EXCEPT
				SELECT Id
				FROM #tblOldDistinctTextList
				WHERE OWPMatchId = em.OWPMatchId
				)

		-- Insert new Provider
		DELETE
		FROM #tblTextList

		DELETE
		FROM #tblDistinctTextList

		DELETE
		FROM #tblOldDistinctTextList

		INSERT INTO #tblTextList (
			OWPMatchId
			,[Text]
			)
		SELECT m.OWPMatchId
			,CAST(RTRIM(LTRIM(d.val)) AS NVARCHAR(100))
		FROM #tblMatch AS m
			CROSS APPLY dbo.fnc_SplitStrings(REPLACE(m.[Provider], '/', ','), ',') AS d
		WHERE m.[Provider] <> ''
			AND RTRIM(LTRIM(d.val)) <> ''

		INSERT INTO #tblDistinctTextList (
			OWPMatchId
			,[Text]
			)
		SELECT OWPMatchId
			,[Text]
		FROM #tblTextList
		GROUP BY OWPMatchId
			,[Text]
		ORDER BY MIN(OrderId) ASC

		INSERT INTO dbo.[Provider] (ProviderName)
		SELECT DISTINCT tl.[Text]
		FROM #tblDistinctTextList AS tl
		WHERE NOT EXISTS (
				SELECT 1
				FROM dbo.[Provider] WITH (NOLOCK)
				WHERE ProviderName = tl.[Text]
				)

		UPDATE tl
		SET tl.Id = tv.ProviderId
		FROM #tblDistinctTextList AS tl
			INNER JOIN dbo.[Provider] AS tv WITH (NOLOCK) ON tl.[Text] = tv.ProviderName

		UPDATE m
		SET m.[Provider] = STUFF((
					SELECT ',' + CAST(Id AS VARCHAR(10))
					FROM #tblDistinctTextList AS tl
					WHERE tl.OWPMatchId = m.OWPMatchId
					FOR XML PATH('')
					), 1, 1, '')
		FROM #tblMatch AS m
		WHERE m.[Provider] <> ''

		-- get matches edited Provider
		INSERT INTO #tblOldDistinctTextList (
			OWPMatchId
			,Id
			,[Text]
			)
		SELECT em.OWPMatchId
			,p.ProviderId
			,p.ProviderName
		FROM #tblExistedMatch AS em
			INNER JOIN #tblOldMatchInfo AS omi ON em.OWPMatchId = omi.OWPMatchId
			CROSS APPLY dbo.fnc_SplitStrings(omi.Provider, ',') AS f
			INNER JOIN dbo.Provider AS p WITH (NOLOCK) ON f.val = p.ProviderId

		INSERT INTO #tblMatchEditedInfo (
			OWPMatchId
			,OldValue
			,NewValue
			,MessageTemplateCode
			)
		SELECT em.OWPMatchId
			,ISNULL(STUFF((
						SELECT ', ' + [Text]
						FROM #tblOldDistinctTextList AS old
						WHERE old.OWPMatchId = em.OWPMatchId
						FOR XML PATH('')
						), 1, 2, ''), '')
			,ISNULL(STUFF((
						SELECT ', ' + [Text]
						FROM #tblDistinctTextList AS new
						WHERE new.OWPMatchId = em.OWPMatchId
						FOR XML PATH('')
						), 1, 2, ''), '')
			,'EditProvider' AS MessageTemplateCode
		FROM #tblExistedMatch AS em
		WHERE EXISTS (
				SELECT Id
				FROM #tblOldDistinctTextList
				WHERE OWPMatchId = em.OWPMatchId
				
				EXCEPT
				SELECT Id
				FROM #tblDistinctTextList
				WHERE OWPMatchId = em.OWPMatchId
				)
			OR EXISTS (
				SELECT Id
				FROM #tblDistinctTextList
				WHERE OWPMatchId = em.OWPMatchId
				
				EXCEPT
				SELECT Id
				FROM #tblOldDistinctTextList
				WHERE OWPMatchId = em.OWPMatchId
				)

		--Update MatchInfo of upload matches which exist in table OWPMatch
		UPDATE mi
		SET mi.NoOfHDP = m.NoOfHDP
			,mi.Channel = m.Channel
			,mi.WB = m.WB
			,mi.[Provider] = m.[Provider]
			,mi.Runner = m.Runner
			,mi.Phone = m.Phone
			,mi.KOTimeRemark = m.MatchOffer
			,mi.TVCode = m.TV
			,mi.Agent = m.Agent
			,mi.IsSelectedUpdatedDate = GETDATE()
			,mi.IsSelected = 1
			,mi.SelectedBy = @UserId
			,mi.[Round] = m.[Round]
			,mi.Division = m.Division
			,mi.Remark = m.Remark
			,mi.Website1 = m.Website1
			,mi.Website2 = m.Website2
			,mi.Website3 = m.Website3
			,mi.Website4 = m.Website4
			,mi.MatchStatus = m.MatchStatus
		FROM dbo.MatchInfo AS mi WITH (ROWLOCK)
			INNER JOIN #tblExistedMatch AS em ON mi.OWPMatchId = em.OWPMatchId
			INNER JOIN #tblMatch AS m ON m.OWPMatchId = mi.OWPMatchId

		-- Get list matches edited Phone, IPTV/Channel, WB, OtherTime, MatchOffer, Remark
		INSERT INTO #tblMatchEditedInfo (
			OWPMatchId
			,OldValue
			,NewValue
			,MessageTemplateCode
			)
		SELECT em.OWPMatchId
			,omi.Phone
			,nmi.Phone
			,'EditPhone'
		FROM #tblExistedMatch AS em
			INNER JOIN #tblOldMatchInfo AS omi ON em.OWPMatchId = omi.OWPMatchId
			INNER JOIN dbo.MatchInfo AS nmi WITH (NOLOCK) ON em.OWPMatchId = nmi.OWPMatchId
		WHERE omi.Phone <> nmi.Phone
		
		UNION
		SELECT em.OWPMatchId
			,omi.Channel
			,nmi.Channel
			,'EditChannel'
		FROM #tblExistedMatch AS em
			INNER JOIN #tblOldMatchInfo AS omi ON em.OWPMatchId = omi.OWPMatchId
			INNER JOIN dbo.MatchInfo AS nmi WITH (NOLOCK) ON em.OWPMatchId = nmi.OWPMatchId
		WHERE omi.Channel <> nmi.Channel
		
		UNION
		SELECT em.OWPMatchId
			,omi.WB
			,nmi.WB
			,'EditWB'
		FROM #tblExistedMatch AS em
			INNER JOIN #tblOldMatchInfo AS omi ON em.OWPMatchId = omi.OWPMatchId
			INNER JOIN dbo.MatchInfo AS nmi WITH (NOLOCK) ON em.OWPMatchId = nmi.OWPMatchId
		WHERE omi.WB <> nmi.WB
		
		UNION
		SELECT em.OWPMatchId
			,ISNULL(CONVERT(NVARCHAR(10), oom.OtherTime, 100), '')
			,ISNULL(CONVERT(NVARCHAR(10), nom.OtherTime, 100), '')
			,'EditOtherTime'
		FROM #tblExistedMatch AS em
			INNER JOIN #tblOldOWPMatch AS oom ON em.OWPMatchId = oom.OWPMatchId
			INNER JOIN dbo.OWPMatch AS nom WITH (NOLOCK) ON em.OWPMatchId = nom.OWPMatchId
		WHERE (
				oom.OtherTime IS NOT NULL
				AND nom.OtherTime IS NOT NULL
				AND oom.OtherTime <> nom.OtherTime
				)
			OR (
				oom.OtherTime IS NULL
				AND nom.OtherTime IS NOT NULL
				)
			OR (
				oom.OtherTime IS NOT NULL
				AND nom.OtherTime IS NULL
				)
		
		UNION
		SELECT em.OWPMatchId
			,omi.KOTimeRemark
			,nmi.KOTimeRemark
			,'EditMatchOffer'
		FROM #tblExistedMatch AS em
			INNER JOIN #tblOldMatchInfo AS omi ON em.OWPMatchId = omi.OWPMatchId
			INNER JOIN dbo.MatchInfo AS nmi WITH (NOLOCK) ON em.OWPMatchId = nmi.OWPMatchId
		WHERE omi.KOTimeRemark <> nmi.KOTimeRemark
		
		UNION
		SELECT em.OWPMatchId
			,omi.[Round]
			,nmi.[Round]
			,'EditRound'
		FROM #tblExistedMatch AS em
			INNER JOIN #tblOldMatchInfo AS omi ON em.OWPMatchId = omi.OWPMatchId
			INNER JOIN dbo.MatchInfo AS nmi WITH (NOLOCK) ON em.OWPMatchId = nmi.OWPMatchId
		WHERE omi.[Round] <> nmi.[Round]
		
		UNION
		SELECT em.OWPMatchId
			,omi.Division
			,nmi.Division
			,'EditDivision'
		FROM #tblExistedMatch AS em
			INNER JOIN #tblOldMatchInfo AS omi ON em.OWPMatchId = omi.OWPMatchId
			INNER JOIN dbo.MatchInfo AS nmi WITH (NOLOCK) ON em.OWPMatchId = nmi.OWPMatchId
		WHERE omi.Division <> nmi.Division
		
		UNION
		SELECT em.OWPMatchId
			,omi.Remark
			,nmi.Remark
			,'EditRemark'
		FROM #tblExistedMatch AS em
			INNER JOIN #tblOldMatchInfo AS omi ON em.OWPMatchId = omi.OWPMatchId
			INNER JOIN dbo.MatchInfo AS nmi WITH (NOLOCK) ON em.OWPMatchId = nmi.OWPMatchId
		WHERE omi.Remark <> nmi.Remark
		
		UNION
		SELECT em.OWPMatchId
			,omi.NoOfHDP
			,nmi.NoOfHDP
			,'EditNoOfHDP'
		FROM #tblExistedMatch AS em
			INNER JOIN #tblOldMatchInfo AS omi ON em.OWPMatchId = omi.OWPMatchId
			INNER JOIN dbo.MatchInfo AS nmi WITH (NOLOCK) ON em.OWPMatchId = nmi.OWPMatchId
		WHERE omi.NoOfHDP <> nmi.NoOfHDP

		-- send message by condition date
		SELECT @FromTimeSendMessage = FromTime
			,@ToTimeSendMessage = ToTime
			,@FromTimeSendMessageSpecialBettype = FromTimeForSpecialBettype
			,@ToTimeSendMessageSpecialBettype = ToTimeForSpecialBettype
		FROM dbo.fnc_GetDateTimeForTraderViewTime()

		--Store list matchs edited in Time Range
		INSERT INTO #tblMatchEditedInTimeRange (
			OWPMatchId
			,MessageTemplateCode
			,OldValue
			,NewValue
			,ParentMatchId
			)
		SELECT match.OWPMatchId
			,match.MessageTemplateCode
			,match.OldValue
			,match.NewValue
			,mm.ParentMatchId
		FROM #tblMatchEditedInfo AS match
			INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON match.OWPMatchId = om.OWPMatchId
			LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON match.OWPMatchId = mm.MinorMatchId
		WHERE (
				(
					mm.MinorBettypeId IS NULL
					AND om.EventDateTime >= @FromTimeSendMessage
					AND om.EventDateTime <= @ToTimeSendMessage
					)
				OR (
					mm.MinorBettypeId IS NOT NULL
					AND 1 = (CASE 
						WHEN EXISTS (
								SELECT 1
								FROM #tblCornerBookingBetTypes
								WHERE MinorBettypeId = mm.MinorBettypeId
								) THEN CASE 
								WHEN om.EventDateTime >= @FromTimeSendMessageSpecialBettype
									AND om.EventDateTime <= @ToTimeSendMessageSpecialBettype THEN 1
								ELSE 0
								END
						ELSE CASE 
								WHEN om.EventDateTime >= @FromTimeSendMessage
									AND om.EventDateTime <= @ToTimeSendMessage THEN 1
								ELSE 0
								END END
						)
					)
				)
			AND (
				match.MessageTemplateCode <> 'EditPhone'
				OR (
					match.MessageTemplateCode = 'EditPhone'
					AND DATEDIFF(MINUTE, @CurrentDateTimeGMTplus8, om.EventDateTime) <= 60
					)
				)

		--Insert MatchInfo of new matches
		INSERT INTO dbo.MatchInfo (
			OWPMatchId
			,NoOfHDP
			,Channel
			,WB
			,[Provider]
			,Runner
			,Phone
			,KOTimeRemark
			,TVCode
			,Agent
			,IsSelectedUpdatedDate
			,IsSelected
			,SelectedBy
			,[Round]
			,Division
			,Remark
			,Website1
			,Website2
			,Website3
			,Website4
			,MatchStatus
			)
		SELECT m.OWPMatchId
			,m.NoOfHDP
			,m.Channel
			,m.WB
			,m.[Provider]
			,m.Runner
			,m.Phone
			,m.MatchOffer
			,m.TV
			,m.Agent
			,GETDATE()
			,1
			,@UserId
			,m.[Round]
			,m.Division
			,m.Remark
			,m.Website1
			,m.Website2
			,m.Website3
			,m.Website4
			,m.MatchStatus
		FROM #tblMatch AS m
			INNER JOIN #tblNewMatch AS nm ON m.OWPMatchId = nm.OWPMatchId

		--Deselect matches same upload time but not uploaded
		UPDATE mi
		SET mi.IsSelected = 0
			,mi.SelectedBy = @UserId
			,mi.IsSelectedUpdatedDate = GETDATE()
		FROM dbo.MatchInfo AS mi WITH (ROWLOCK)
			INNER JOIN #tblRemoveMatch AS rm ON mi.OWPMatchId = rm.OWPMatchId

		--List of minor matches from upload matches
		INSERT INTO #tblMinorMatch (
			MinorMatchId
			,MinorBetTypeId
			,ParentMatchId
			)
		SELECT minor.OWPMatchId
			,minor.MinorBetTypeId
			,parent.OWPMatchId
		FROM #tblMatch AS minor
			INNER JOIN #tblMatch AS parent ON minor.ParentRowNumber = parent.RowNumber
		WHERE minor.ParentRowNumber IS NOT NULL

		-- Insert data to MinorMatch
		MERGE dbo.MinorMatch WITH (ROWLOCK) AS mm
		USING (
			SELECT MinorMatchId
				,MinorBetTypeId
				,ParentMatchId
			FROM #tblMinorMatch
			) AS tmn ON mm.MinorMatchId = tmn.MinorMatchId
		WHEN MATCHED
			AND mm.MinorBetTypeId = tmn.MinorMatchId
			AND mm.ParentMatchId = tmn.ParentMatchId THEN
				UPDATE
				SET mm.MinorBetTypeId = tmn.MinorBetTypeId
					,mm.ParentMatchId = tmn.ParentMatchId
		WHEN NOT MATCHED BY TARGET THEN
				INSERT (
					MinorMatchId
					,MinorBetTypeId
					,ParentMatchId
					,IsRepresented
					)
				VALUES (
					tmn.MinorMatchId
					,tmn.MinorBetTypeId
					,tmn.ParentMatchId
					,1
					)
		OUTPUT $ACTION
			,CASE 
				WHEN inserted.MinorMatchId IS NOT NULL THEN inserted.MinorMatchId
				ELSE deleted.MinorMatchId
				END
			,CASE 
				WHEN inserted.MinorBetTypeId IS NOT NULL THEN inserted.MinorBetTypeId
				ELSE deleted.MinorBetTypeId
				END
			,CASE 
				WHEN inserted.ParentMatchId IS NOT NULL THEN inserted.ParentMatchId
				ELSE deleted.ParentMatchId
				END
		INTO #tblMinorMatchLog;

		--Update match status of minor match same as parent match if parent match status is 'Cancel', 'Postponed', 'Suspended'
		UPDATE mi
		SET mi.MatchStatus = parent.MatchStatus
		FROM dbo.MinorMatch AS mm WITH (NOLOCK)
			INNER JOIN dbo.MatchInfo AS mi WITH (ROWLOCK) ON mm.MinorMatchId = mi.OWPMatchId
			INNER JOIN (
			SELECT m.OWPMatchId
				,mi.MatchStatus
			FROM #tblMatch AS m
				INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
				INNER JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON mm.MinorMatchId = m.OWPMatchId
			WHERE mi.MatchStatus IN (@str_Cancel, @str_Suspended, @str_Postponed)
			) AS parent ON mm.ParentMatchId = parent.OWPMatchId

		--List of upload notes
		INSERT INTO #tblMatchNote (
			OWPMatchId
			,CreatedBy
			,Note
			)
		SELECT m.OWPMatchId
			,@UserId
			,n.c.value('@n', 'varchar(4000)') AS Note
		FROM #tblMatch AS m
			OUTER APPLY m.Note.nodes('Root/r') AS n(c)
		WHERE m.Note IS NOT NULL

		-- Delete old notes of upload matches
		DELETE mn
		OUTPUT 'DELETE'
			,deleted.MatchNoteId
			,deleted.OWPMatchId
			,deleted.CreatedBy
			,deleted.Note
		INTO #tblMatchNoteLog
		FROM dbo.MatchNote AS mn WITH (ROWLOCK)
			INNER JOIN #tblMatch AS m ON mn.OWPMatchId = m.OWPMatchId
			LEFT JOIN #tblMatchNote AS tmn ON mn.OWPMatchId = tmn.OWPMatchId
			AND NULLIF(mn.Note, '') = NULLIF(tmn.Note, '')
		WHERE tmn.OWPMatchId IS NULL

		-- Insert notes of upload matches
		INSERT INTO dbo.MatchNote (
			OWPMatchId
			,CreatedBy
			,Note
			)
		OUTPUT 'INSERTED'
			,inserted.MatchNoteId
			,inserted.OWPMatchId
			,inserted.CreatedBy
			,inserted.Note
		INTO #tblMatchNoteLog
		SELECT tmn.OWPMatchId
			,tmn.CreatedBy
			,tmn.Note
		FROM #tblMatchNote AS tmn
		WHERE tmn.Note <> ''
			AND NOT EXISTS (
				SELECT 1
				FROM dbo.MatchNote AS mn WITH (NOLOCK)
				WHERE mn.OWPMatchId = tmn.OWPMatchId
					AND NULLIF(mn.Note, '') = NULLIF(tmn.Note, '')
				)

		-- Fill MatchSetting of upload matches
		INSERT INTO #tblMatchSetting (
			OWPMatchId
			,BetType
			,MaxBet
			,Spread
			)
		SELECT OWPMatchId
			,1
			,MaxBetHDP
			,SpreadHDP
		FROM #tblMatch
		WHERE MaxBetHDP IS NOT NULL
			OR SpreadHDP IS NOT NULL
		
		UNION ALL
		SELECT OWPMatchId
			,3
			,MaxBetOU
			,SpreadOU
		FROM #tblMatch
		WHERE MaxBetOU IS NOT NULL
			OR SpreadOU IS NOT NULL
		
		UNION ALL
		SELECT OWPMatchId
			,5
			,MaxBet1X2
			,Spread1X2
		FROM #tblMatch
		WHERE MaxBet1X2 IS NOT NULL
			OR Spread1X2 IS NOT NULL
		
		UNION ALL
		SELECT OWPMatchId
			,7
			,MaxBet1HHDP
			,Spread1HHDP
		FROM #tblMatch
		WHERE MaxBet1HHDP IS NOT NULL
			OR Spread1HHDP IS NOT NULL
		
		UNION ALL
		SELECT OWPMatchId
			,8
			,MaxBet1HOU
			,Spread1HOU
		FROM #tblMatch
		WHERE MaxBet1HOU IS NOT NULL
			OR Spread1HOU IS NOT NULL
		
		UNION ALL
		SELECT OWPMatchId
			,15
			,MaxBet1H1X2
			,Spread1H1X2
		FROM #tblMatch
		WHERE MaxBet1H1X2 IS NOT NULL
			OR Spread1H1X2 IS NOT NULL

		-- Remove MatchSetting of matches not in upload
		DELETE ms
		OUTPUT 'DELETE'
			,deleted.OWPMatchId
			,deleted.Bettype
			,deleted.Maxbet
			,deleted.Spread
		INTO #tblMatchSettingLog
		FROM dbo.MatchSetting AS ms WITH (ROWLOCK)
			INNER JOIN #tblRemoveMatch AS rm WITH (NOLOCK) ON ms.OWPMatchId = rm.OWPMatchId

		-- Delete old MatchSetting of upload matches
		DELETE ms
		OUTPUT 'DELETE'
			,deleted.OWPMatchId
			,deleted.Bettype
			,deleted.Maxbet
			,deleted.Spread
		INTO #tblMatchSettingLog
		FROM dbo.MatchSetting AS ms WITH (ROWLOCK)
			INNER JOIN #tblMatch AS m ON ms.OWPMatchId = m.OWPMatchId
			LEFT JOIN #tblMatchSetting AS tms ON ms.OWPMatchId = tms.OWPMatchId
			AND ms.BetType = tms.BetType
		WHERE tms.OWPMatchId IS NULL

		-- Insert, Update MatchSetting of upload matches
		MERGE dbo.MatchSetting WITH (ROWLOCK) AS ms
		USING (
			SELECT OWPMatchId
				,BetType
				,MaxBet
				,Spread
			FROM #tblMatchSetting
			) AS tms ON ms.OWPMatchId = tms.OWPMatchId
				AND ms.BetType = tms.BetType
		WHEN MATCHED
			AND (
				ISNULL(ms.MaxBet, - 1) <> ISNULL(tms.MaxBet, - 1)
				OR ISNULL(ms.Spread, - 1) <> ISNULL(tms.Spread, - 1)
				) THEN
				UPDATE
				SET ms.MaxBet = tms.MaxBet
					,ms.Spread = tms.Spread
		WHEN NOT MATCHED BY TARGET THEN
				INSERT (
					OWPMatchId
					,Bettype
					,MaxBet
					,Spread
					)
				VALUES (
					tms.OWPMatchId
					,tms.Bettype
					,tms.MaxBet
					,tms.Spread
					)
		OUTPUT $ACTION
			,CASE 
				WHEN inserted.OWPMatchId IS NOT NULL THEN inserted.OWPMatchId
				ELSE deleted.OWPMatchId
				END
			,CASE 
				WHEN inserted.Bettype IS NOT NULL THEN inserted.Bettype
				ELSE deleted.Bettype
				END
			,CASE 
				WHEN inserted.Maxbet IS NOT NULL THEN inserted.Maxbet
				ELSE deleted.Maxbet
				END
			,CASE 
				WHEN inserted.Spread IS NOT NULL THEN inserted.Spread
				ELSE deleted.Spread
				END
		INTO #tblMatchSettingLog;

		-- Fill main assignment of upload matches
		INSERT INTO #tblAssignment (
			OWPMatchId
			,BetType
			,AssignmentType
			,UserId
			)
		SELECT OWPMatchId
			,(CASE TraderBettype
				WHEN 'TraderHDP' THEN 1
				WHEN 'Trader1HHDP' THEN 7
				WHEN 'TraderOU' THEN 3
				WHEN 'Trader1HOU' THEN 8
				WHEN 'Trader1X2' THEN 5
				WHEN 'Trader1H1X2' THEN 15
				WHEN 'LA' THEN - 1002 END
				) AS Bettype
			,1
			,u.UserId
		FROM #tblMatch AS m
		UNPIVOT(Trader FOR TraderBettype IN (TraderHDP, Trader1HHDP, TraderOU, Trader1HOU, Trader1X2, Trader1H1X2, LA)) AS unpvt
			INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON Trader = u.NickName
			OR Trader = u.Username
		WHERE Trader <> ''

		-- Fill other assignment of upload matches
		INSERT INTO #tblAssignment (
			OWPMatchId
			,BetType
			,AssignmentType
			,UserId
			,AssignmentNote
			)
		SELECT m.OWPMatchId
			,ot.Bettype
			,2
			,u.UserId
			,ot.Note
		FROM dbo.AssignmentUploadingOtherTrader AS ot WITH (NOLOCK)
			INNER JOIN #tblMatch AS m ON ot.RowNumber = m.RowNumber
			LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON ot.Trader = u.NickName
			OR ot.Trader = u.Username
		WHERE ot.SessionId = @SessionId
			AND (
				ot.Trader <> ''
				OR ot.Note <> ''
				)
		ORDER BY ot.AssignmentId ASC

		-- Remove assignment (main+other) of matches not in upload file
		DELETE a
		OUTPUT 'DELETE'
			,deleted.OWPMatchId
			,deleted.Bettype
			,deleted.AssignmentType
			,deleted.UserId
			,deleted.AssignmentNote
		INTO #tblAssignmentLog([Action], OWPMatchId, BetType, AssignmentType, OldUserId, OldAssignmentNote)
		FROM dbo.Assignment AS a WITH (ROWLOCK)
			INNER JOIN #tblRemoveMatch AS rm WITH (NOLOCK) ON a.OWPMatchId = rm.OWPMatchId

		-- Always to remove other assignment of upload matches (to keep other assignments in order)
		DELETE a
		OUTPUT deleted.OWPMatchId
			,deleted.Bettype
			,deleted.UserId
			,deleted.AssignmentNote
		INTO #tblOldOtherAssignment
		FROM dbo.Assignment AS a WITH (ROWLOCK)
			INNER JOIN #tblMatch AS m ON a.OWPMatchId = m.OWPMatchId
		WHERE a.AssignmentType = 2

		-- Delete old main assignment of upload matches (match uploaded but assignment not be included)
		DELETE a
		OUTPUT 'DELETE'
			,deleted.OWPMatchId
			,deleted.Bettype
			,deleted.AssignmentType
			,deleted.UserId
			,deleted.AssignmentNote
		INTO #tblAssignmentLog([Action], OWPMatchId, BetType, AssignmentType, OldUserId, OldAssignmentNote)
		FROM dbo.Assignment AS a WITH (ROWLOCK)
			INNER JOIN #tblMatch AS m ON a.OWPMatchId = m.OWPMatchId
			AND a.AssignmentType = 1
			LEFT JOIN #tblAssignment AS ta ON a.OWPMatchId = ta.OWPMatchId
			AND a.BetType = ta.BetType
		WHERE ta.OWPMatchId IS NULL

		-- Insert or update main assignment of upload matches
		MERGE dbo.Assignment WITH (ROWLOCK) AS a
		USING (
			SELECT OWPMatchId
				,BetType
				,UserId
			FROM #tblAssignment
			WHERE AssignmentType = 1
			) AS ta ON a.OWPMatchId = ta.OWPMatchId
				AND a.BetType = ta.BetType
		WHEN MATCHED
			AND a.UserId <> ta.UserId THEN
				UPDATE
				SET a.UserId = ta.UserId
		WHEN NOT MATCHED BY TARGET THEN
				INSERT (
					OWPMatchId
					,Bettype
					,AssignmentType
					,UserId
					)
				VALUES (
					ta.OWPMatchId
					,ta.Bettype
					,1
					,ta.UserId
					)
		OUTPUT $ACTION -- value is 'INSERT' OR 'UPDATE'
			,CASE 
				WHEN inserted.OWPMatchId IS NOT NULL THEN inserted.OWPMatchId
				ELSE deleted.OWPMatchId
				END
			,CASE 
				WHEN inserted.Bettype IS NOT NULL THEN inserted.Bettype
				ELSE deleted.Bettype
				END
			,CASE 
				WHEN inserted.AssignmentType IS NOT NULL THEN inserted.AssignmentType
				ELSE deleted.AssignmentType
				END
			,CASE 
				WHEN inserted.UserId IS NOT NULL THEN inserted.UserId
				ELSE NULL
				END
			,CASE 
				WHEN inserted.AssignmentNote IS NOT NULL THEN inserted.AssignmentNote
				ELSE NULL
				END
			,deleted.UserId
			,deleted.AssignmentNote
		INTO #tblAssignmentLog([Action], OWPMatchId, Bettype, AssignmentType, UserId, AssignmentNote, OldUserId, OldAssignmentNote);

		-- Insert other assignment of upload matches
		INSERT INTO dbo.Assignment (
			OWPMatchId
			,Bettype
			,AssignmentType
			,UserId
			,AssignmentNote
			)
		SELECT ta.OWPMatchId
			,ta.Bettype
			,ta.AssignmentType
			,ta.UserId
			,ta.AssignmentNote
		FROM #tblAssignment AS ta
			INNER JOIN #tblMatch AS m ON ta.OWPMatchId = m.OWPMatchId
		WHERE ta.AssignmentType = 2

		-- when other assignment of upload match has changed and we remove other assignment and insert new other assignment.
		-- So we need compare before & after to get changed (DELETE or INSERT). Note: can't detect case UPDATE
		INSERT INTO #tblAssignmentLog (
			[Action]
			,OWPMatchId
			,BetType
			,AssignmentType
			,UserId
			,AssignmentNote
			,OldUserId
			,OldAssignmentNote
			)
		SELECT CASE 
				WHEN a.OWPMatchId IS NULL THEN 'DELETE'
				ELSE 'INSERT'
				END
			,ISNULL(a.OWPMatchId, oa.OWPMatchId)
			,ISNULL(a.Bettype, oa.Bettype)
			,2
			,a.UserId
			,a.AssignmentNote
			,oa.UserId
			,oa.AssignmentNote
		FROM (
			SELECT OWPMatchId
				,BetType
				,AssignmentType
				,UserId
				,AssignmentNote
			FROM #tblAssignment
			WHERE AssignmentType = 2
			) AS a
			FULL JOIN #tblOldOtherAssignment AS oa ON a.OWPMatchId = oa.OWPMatchId
			AND a.BetType = oa.BetType
			AND ISNULL(a.UserId, 0) = ISNULL(oa.UserId, 0)
			AND ISNULL(a.AssignmentNote, '') = ISNULL(oa.AssignmentNote, '')
		WHERE a.OWPMatchId IS NULL
			OR oa.OWPMatchId IS NULL

		-- when change status of match to 'Live', we also need send message for assignee in these matches
		INSERT INTO #tblAssignmentLog (
			[Action]
			,OWPMatchId
			,BetType
			,AssignmentType
			,UserId
			,AssignmentNote
			)
		SELECT d.Action
			,d.OWPMatchId
			,d.Bettype
			,d.AssignmentType
			,d.UserId
			,d.AssignmentNote
		FROM (
			SELECT 'INSERT' AS [Action]
				,mi.OWPMatchId AS OWPMatchId
				,a.Bettype AS Bettype
				,a.AssignmentType AS AssignmentType
				,a.UserId AS UserId
				,a.AssignmentNote AS AssignmentNote
			FROM dbo.MatchInfo AS mi WITH (NOLOCK)
				INNER JOIN #tblOldMatchInfo AS omi ON mi.OWPMatchId = omi.OWPMatchId
				AND mi.MatchStatus = @str_Live
				AND omi.MatchStatus <> @str_Live
				INNER JOIN dbo.Assignment AS a WITH (NOLOCK) ON a.OWPMatchId = mi.OWPMatchId
			) AS d
		WHERE NOT EXISTS (
				SELECT 1
				FROM #tblAssignmentLog AS a
				WHERE d.[Action] = a.[Action]
					AND d.OWPMatchId = a.OWPMatchId
					AND d.Bettype = a.BetType
					AND d.AssignmentType = a.AssignmentType
					AND ISNULL(d.UserId, 0) = ISNULL(a.UserId, 0)
					AND ISNULL(d.AssignmentNote, '') = ISNULL(a.AssignmentNote, '')
				)

		-- get message template
		SELECT @MessageInsertAssignment = mt.MsgTemplateContent
			,@MessageInsertAssignmentId = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'AssignmentInsert'

		SELECT @MessageDeleteAssignment = mt.MsgTemplateContent
			,@MessageDeleteAssignmentId = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'AssignmentDelete'

		SELECT @MessageMatchStatus = mt.MsgTemplateContent
			,@MessageMatchStatusId = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'MatchStatus'

		SELECT @MessageMinorMatchStatus = mt.MsgTemplateContent
			,@MessageMinorMatchStatusId = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'MinorMatchStatus'

		SELECT @MessageInsertOtherAssignment = mt.MsgTemplateContent
			,@MessageInsertOtherAssignmentId = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'OtherAssignmentInsert'

		SELECT @MessageDeleteOtherAssignment = mt.MsgTemplateContent
			,@MessageDeleteOtherAssignmentId = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'OtherAssignmentDelete'

		SELECT @MessageChangeOfAssignment = mt.MsgTemplateContent
			,@MessageChangeOfAssignmentId = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'ChangeOfAssignment'

		--Store list of upload matchs in Time Range
		INSERT INTO #tblMatchInTimeRange (
			OWPMatchId
			,ParentMatchId
			)
		SELECT m.OWPMatchId
			,ISNULL(mm.ParentMatchId, m.OWPMatchId)
		FROM #tblMatch AS m
			INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON m.OWPMatchId = om.OWPMatchId
			LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON m.OWPMatchId = mm.MinorMatchId
		WHERE (
				(
					mm.MinorBettypeId IS NULL
					AND om.EventDateTime >= @FromTimeSendMessage
					AND om.EventDateTime <= @ToTimeSendMessage
					)
				OR (
					mm.MinorBettypeId IS NOT NULL
					AND 1 = (CASE 
						WHEN EXISTS (
								SELECT 1
								FROM #tblCornerBookingBetTypes
								WHERE MinorBettypeId = mm.MinorBettypeId
								) THEN CASE 
								WHEN om.EventDateTime >= @FromTimeSendMessageSpecialBettype
									AND om.EventDateTime <= @ToTimeSendMessageSpecialBettype THEN 1
								ELSE 0
								END
						ELSE CASE 
								WHEN om.EventDateTime >= @FromTimeSendMessage
									AND om.EventDateTime <= @ToTimeSendMessage THEN 1
								ELSE 0
								END END
						)
					)
				)

		-- update Username & oldUsername
		UPDATE a
		SET a.Username = ISNULL(u.Nickname, u.Username)
		FROM #tblAssignmentLog AS a
			INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON u.UserId = a.UserId

		UPDATE a
		SET a.OldUsername = ISNULL(u.Nickname, u.Username)
		FROM #tblAssignmentLog AS a
			INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON u.UserId = a.OldUserId

		INSERT INTO #tblAssignmentInTimeRange (
			[Action]
			,OWPMatchId
			,ParentMatchId
			,BetType
			,AssignmentType
			,UserId
			,Username
			,AssignmentNote
			,OldUserId
			,OldUsername
			,OldAssignmentNote
			,EventName
			)
		SELECT [Action]
			,al.OWPMatchId
			,mt.ParentMatchId
			,BetType
			,AssignmentType
			,UserId
			,Username
			,AssignmentNote
			,OldUserId
			,OldUsername
			,OldAssignmentNote
			,h.OWPTeamName + ' vs ' + a.OWPTeamName + ' - bettype: ' + (CASE 
				WHEN mm.MinorMatchId IS NULL THEN mjb.ShortName
				ELSE mb.MinorBettypeName END
				)
		FROM #tblAssignmentLog AS al
			INNER JOIN #tblMatchInTimeRange AS mt ON al.OWPMatchId = mt.OWPMatchId
			INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON m.OWPMatchId = mt.ParentMatchId
			INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON h.OWPTeamId = m.OWPHomeId
			INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON a.OWPTeamId = m.OWPAwayId
			LEFT JOIN dbo.MajorBettype AS mjb WITH (NOLOCK) ON al.BetType = mjb.BettypeId
			LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON al.OWPMatchId = mm.MinorMatchId
			LEFT JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mm.MinorBettypeId = mb.ParentBettypeId
			AND al.BetType = mb.InheritedBettypeId

		-- send message to trader unassigned
		INSERT INTO #tblAssignmentMessage (
			UserId
			,MessageContent
			,MessageTypeId
			,NotificationSettingId
			,IsImportant
			)
		SELECT a.OldUserId
			,REPLACE(CASE 
					WHEN a.AssignmentType = 1 THEN @MessageDeleteAssignment
					ELSE REPLACE(@MessageDeleteOtherAssignment, '<note>', RTRIM(LTRIM(REPLACE(a.OldAssignmentNote, '#<user>', ''))))
					END, '<event>', a.EventName)
			,CASE 
				WHEN a.AssignmentType = 1 THEN @MessageDeleteAssignmentId
				ELSE @MessageDeleteOtherAssignmentId
				END
			,1
			,1
		FROM #tblAssignmentInTimeRange a
		WHERE a.OldUserId IS NOT NULL
			AND a.[Action] IN ('DELETE', 'UPDATE')

		-- send message to trader assigned
		INSERT INTO #tblAssignmentMessage (
			UserId
			,MessageContent
			,MessageTypeId
			,NotificationSettingId
			,IsImportant
			)
		SELECT a.UserId
			,REPLACE(CASE 
					WHEN a.AssignmentType = 1 THEN @MessageInsertAssignment
					ELSE REPLACE(@MessageInsertOtherAssignment, '<note>', RTRIM(LTRIM(REPLACE(a.AssignmentNote, '#<user>', ''))))
					END, '<event>', a.EventName)
			,CASE 
				WHEN a.AssignmentType = 1 THEN @MessageInsertAssignmentId
				ELSE @MessageInsertOtherAssignmentId
				END
			,1
			,1
		FROM #tblAssignmentInTimeRange a
		WHERE a.UserId IS NOT NULL
			AND a.[Action] IN ('INSERT', 'UPDATE')

		-- send message to trader have match assigned to inform about assignment edited
		INSERT INTO #tblChangeOfAssignmentMessage (
			OWPMatchId
			,ParentMatchId
			,UserId
			,MessageContent
			)
		SELECT a.OWPMatchId
			,a.ParentMatchId
			,ISNULL(a.UserId, a.OldUserId)
			,REPLACE(REPLACE(REPLACE(REPLACE(@MessageChangeOfAssignment, '<newAssignee>', CASE 
								WHEN a.[Action] <> 'DELETE' THEN CASE 
										WHEN a.AssignmentType = 1 THEN '#' + a.Username
										ELSE RTRIM(LTRIM(REPLACE(a.AssignmentNote, '#<user>', CASE 
															WHEN a.Username IS NOT NULL THEN '#' + a.Username
															ELSE ''
															END)))
										END
								ELSE ''
								END), '<event>', a.EventName), '<user>', @Username), '<oldAssignee>', CASE 
					WHEN a.[Action] <> 'INSERT' THEN CASE 
							WHEN a.AssignmentType = 1 THEN '#' + a.OldUsername
							ELSE RTRIM(LTRIM(REPLACE(a.OldAssignmentNote, '#<user>', CASE 
												WHEN a.OldUsername IS NOT NULL THEN '#' + a.OldUsername
												ELSE ''
												END)))
							END
					ELSE ''
					END) AS MessageContent
		FROM #tblAssignmentInTimeRange AS a

		INSERT INTO #tblAssignmentMessage (
			UserId
			,MessageContent
			,MessageTypeId
			,NotificationSettingId
			,IsImportant
			)
		SELECT a.UserId
			,m.MessageContent
			,@MessageChangeOfAssignmentId
			,2
			,0
		FROM #tblChangeOfAssignmentMessage AS m
			CROSS JOIN (
			SELECT DISTINCT a.UserId
				,ISNULL(mm.ParentMatchId, a.OWPMatchId) AS ParentMatchId
			FROM #tblAssignment AS a
				LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON a.OWPMatchId = mm.MinorMatchId
			WHERE a.UserId IS NOT NULL
			) AS a
		WHERE m.UserId <> a.UserId
			AND m.ParentMatchId = a.ParentMatchId

		INSERT INTO #tblMessage
		SELECT m.UserId
			,m.MessageContent
			,m.MessageTypeId
			,m.IsImportant
		FROM #tblAssignmentMessage AS m
			LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = m.NotificationSettingId
			LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			AND nsm.UserId = m.UserId
		WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'

		-- send message	if MatchStatus changed to Cancel, Suspended or Postponed
		INSERT INTO #tblMessage (
			UserId
			,MessageContent
			,MessageTypeId
			,IsImportant
			)
		SELECT al.UserId
			,REPLACE(REPLACE(REPLACE(CASE 
							WHEN al.MinorBettypeId IS NULL THEN @MessageMatchStatus
							ELSE @MessageMinorMatchStatus
							END, '<event>', h.OWPTeamName + ' vs ' + a.OWPTeamName), '<bettype>', ISNULL(al.MinorBettypeName, '')), '<status>', al.MatchStatus) AS MessageContent
			,(CASE 
				WHEN al.MinorBettypeId IS NULL THEN @MessageMatchStatusId
				ELSE @MessageMinorMatchStatusId END
				) AS MessageTypeId
			,1
		FROM (
			SELECT DISTINCT ISNULL(mm.ParentMatchId, mi.OWPMatchId) AS OWPMatchId
				,mi.MatchStatus
				,mm.MinorBettypeId
				,mb.MinorBettypeName
				,ass.UserId
			FROM dbo.MatchInfo AS mi WITH (NOLOCK)
				INNER JOIN #tblOldMatchInfo AS omi ON mi.OWPMatchId = omi.OWPMatchId
				AND mi.MatchStatus <> omi.MatchStatus
				AND mi.MatchStatus <> @str_Live
				INNER JOIN #tblAssignment AS ass ON mi.OWPMatchId = ass.OWPMatchId
				AND ass.UserId IS NOT NULL
				LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON mi.OWPMatchId = mm.MinorMatchId
				LEFT JOIN dbo.MinorBetType AS mb WITH (NOLOCK) ON mm.MinorBettypeId = mb.MinorBettypeId
			WHERE mm.MinorMatchId IS NULL
				OR (
					mm.MinorMatchId IS NOT NULL
					AND mm.MinorBettypeId NOT IN (@Specific15Mins, @Specific10Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
					)
			) AS al
			INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON al.OWPMatchId = m.OWPMatchId
			INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
			INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId

		-- insert message
		MERGE dbo.[Message] WITH (ROWLOCK) AS ms
		USING (
			SELECT m.UserId
				,m.MessageContent
				,m.MessageTypeId
				,m.IsImportant
			FROM #tblMessage AS m
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
					,msn.IsImportant
					,msn.MessageTypeId
					)
		OUTPUT inserted.MessageId
			,msn.UserId
			,@UserId
			,@SessionId
		INTO dbo.MessageUser([MessageId], [UserId], [CreatedBy], [SessionId]);

		/*------Send message edit matchinfo---------*/
		INSERT INTO #tblUsersReceivedMessageUpdateMatchInfo (
			OWPMatchId
			,MessageTemplateCode
			,UserId
			)
		SELECT u.OWPMatchId
			,u.MessageTemplateCode
			,u.UserId
		FROM (
			SELECT tr.OWPMatchId
				,tr.MessageTemplateCode
				,a.UserId
			FROM #tblMatchEditedInTimeRange AS tr
				LEFT JOIN dbo.Assignment AS a WITH (NOLOCK) ON a.OWPMatchId = tr.OWPMatchId
			WHERE tr.ParentMatchId IS NULL
				AND a.UserId IS NOT NULL
			
			UNION
			SELECT tr.OWPMatchId
				,tr.MessageTemplateCode
				,a.UserId
			FROM #tblMatchEditedInTimeRange AS tr
				INNER JOIN dbo.MinorMatch AS mm ON mm.ParentMatchId = tr.OWPMatchId
				LEFT JOIN dbo.Assignment AS a WITH (NOLOCK) ON a.OWPMatchId = mm.MinorMatchId
			WHERE tr.ParentMatchId IS NULL
				AND a.UserId IS NOT NULL
			
			UNION --minor match
			SELECT tr.OWPMatchId
				,tr.MessageTemplateCode
				,a.UserId
			FROM #tblMatchEditedInTimeRange AS tr
				LEFT JOIN dbo.Assignment AS a WITH (NOLOCK) ON a.OWPMatchId = tr.ParentMatchId
			WHERE tr.ParentMatchId IS NOT NULL
				AND a.UserId IS NOT NULL
			
			UNION
			SELECT tr.OWPMatchId
				,tr.MessageTemplateCode
				,a.UserId
			FROM #tblMatchEditedInTimeRange AS tr
				INNER JOIN dbo.MinorMatch AS mm ON mm.ParentMatchId = tr.ParentMatchId
				LEFT JOIN dbo.Assignment AS a WITH (NOLOCK) ON a.OWPMatchId = mm.MinorMatchId
			WHERE tr.ParentMatchId IS NOT NULL
				AND a.UserId IS NOT NULL
			) AS u
			LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = 5
			LEFT JOIN dbo.NotificationSettingMapping AS nm WITH (NOLOCK) ON u.UserId = nm.UserId
			AND nm.NotificationSettingId = 5
		WHERE ISNULL(nm.Value, ns.DefaultValue) = 'True'

		MERGE INTO dbo.[Message] WITH (ROWLOCK)
		USING (
			SELECT tr.OWPMatchId
				,tr.MessageTemplateCode
				,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(mt.MsgTemplateContent, '<user>', @Username), '<home>', home.OWPTeamName), '<away>', away.OWPTeamName), '<bettype>', CASE 
								WHEN mb.MinorBettypeName IS NULL THEN ''
								ELSE ' - bettype: ' + mb.MinorBettypeName
								END), '<oldvalue>', tr.OldValue), '<newvalue>', tr.NewValue) AS MessageContent
				,mt.MsgTemplateId AS MessageTemplateId
			FROM #tblMatchEditedInTimeRange AS tr
				INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON om.OWPMatchId = (CASE 
					WHEN tr.ParentMatchId IS NULL THEN tr.OWPMatchId
					ELSE tr.ParentMatchId END
					)
				LEFT JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
				LEFT JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
				LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON mm.MinorMatchId = tr.OWPMatchId
				LEFT JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mb.[MinorBettypeId] = mm.MinorBettypeId
				LEFT JOIN dbo.MessageTemplate AS mt WITH (NOLOCK) ON tr.MessageTemplateCode = mt.MsgTemplateCode
			) AS im ON 1 = 0
		WHEN NOT MATCHED THEN
				INSERT (
					MessageContent
					,CreatedBy
					,IsImportant
					,MessageType
					)
				VALUES (
					im.MessageContent
					,@UserId
					,0
					,im.MessageTemplateId
					)
		OUTPUT im.OWPMatchId
			,im.MessageTemplateCode
			,inserted.MessageId
		INTO #tblInsertedMessageUpdateMatchInfo(OWPMatchId, MessageTemplateCode, MessageId);

		INSERT INTO dbo.MessageUser (
			MessageId
			,UserId
			,CreatedBy
			,SessionId
			)
		SELECT m.MessageId
			,u.UserId
			,@UserId
			,@SessionId
		FROM #tblUsersReceivedMessageUpdateMatchInfo AS u
			LEFT JOIN #tblInsertedMessageUpdateMatchInfo AS m ON u.OWPMatchId = m.OWPMatchId
			AND u.MessageTemplateCode = m.MessageTemplateCode

		/*----------------------------------------*/
		--Remove minor matches not in upload file in OWPMatch
		DELETE m
		FROM dbo.OWPMatch AS m WITH (ROWLOCK)
			INNER JOIN #tblRemoveMatch AS rm ON rm.OWPMatchId = m.OWPMatchId
			INNER JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON m.OWPMatchId = mm.MinorMatchId

		--Remove minor matches not in upload file in MatchInfo
		DELETE mi
		FROM dbo.MatchInfo AS mi WITH (ROWLOCK)
			INNER JOIN #tblRemoveMatch AS rm ON rm.OWPMatchId = mi.OWPMatchId
			INNER JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON mi.OWPMatchId = mm.MinorMatchId

		--Remove minor matches not in upload file in MinorMatch
		DELETE mm
		FROM dbo.MinorMatch AS mm WITH (ROWLOCK)
			LEFT JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON mm.MinorMatchId = m.OWPMatchId
		WHERE m.OWPMatchId IS NULL

		--create data for Trade5MatchPerDay
		EXEC dbo.OWP_Trade5MatchPerDay_RunAfterInsertAssignment @OWPEventDate = @EventDate

		-- set status of uploading is success
		UPDATE dbo.AssignmentUploadingLog WITH (ROWLOCK)
		SET [Status] = 5 -- success
			,EndDate = GETDATE()
		WHERE SessionId = @SessionId
	END TRY

	BEGIN CATCH
		BEGIN
			-- set status of uploading is failure
			UPDATE dbo.AssignmentUploadingLog WITH (ROWLOCK)
			SET [Status] = 6 -- failure
				,EndDate = GETDATE()
				,LogMessage = ERROR_MESSAGE()
			WHERE SessionId = @SessionId

			SELECT @ErrCode = 1
				,@ErrMsg = 'Uploading Fail.'
		END
	END CATCH

	--drop tables
	DROP TABLE #tblCornerBookingBetTypes

	DROP TABLE #tblMatch

	DROP TABLE #tblExistedMatch

	DROP TABLE #tblNewMatch

	DROP TABLE #tblRemoveMatch

	DROP TABLE #tblMinorMatch

	DROP TABLE #tblMinorMatchLog

	DROP TABLE #tblTeamLog

	DROP TABLE #tblLeagueLog

	DROP TABLE #tblTextList

	DROP TABLE #tblDistinctTextList

	DROP TABLE #tblOldDistinctTextList

	DROP TABLE #tblMatchEditedInfo

	DROP TABLE #tblMatchEditedInTimeRange

	DROP TABLE #tblUsersReceivedMessageUpdateMatchInfo

	DROP TABLE #tblInsertedMessageUpdateMatchInfo

	DROP TABLE #tblOldMatchInfo

	DROP TABLE #tblOldOWPMatch

	DROP TABLE #tblMatchNote

	DROP TABLE #tblMatchNoteLog

	DROP TABLE #tblMatchSetting

	DROP TABLE #tblMatchSettingLog

	DROP TABLE #tblAssignment

	DROP TABLE #tblAssignmentLog

	DROP TABLE #tblChangeOfAssignmentMessage

	DROP TABLE #tblOldOtherAssignment

	DROP TABLE #tblAssignmentMessage
	
	DROP TABLE #tblAssignmentInTimeRange

	DROP TABLE #tblMessage
END