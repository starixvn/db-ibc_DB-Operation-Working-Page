/****** Object:  Stored Procedure dbo.OWP_AssignmentUploading_Submit    Script Date: 6/18/2018 9:30:45 AM ******/
/****** Object:  Stored Procedure dbo.OWP_AssignmentUploading_Submit    Script Date: 6/14/2018 4:26:37 PM ******/
CREATE PROCEDURE [dbo].[OWP_AssignmentUploading_Submit] @UserId INT = 0
	,@SessionId NVARCHAR(100)
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
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @EventDate DATE
		,@KickOffTime TIME
		,@FromDate DATETIME
		,@ToDate DATETIME
		,@FromTime DATETIME = GETDATE()
		,@ToTime DATETIME
		,@StartRun DATETIME = GETDATE()
		,@EndRun DATETIME
		,@Duration INT = 0
		-- Match Setting
		,@HandicapBettype INT = 1
		,@OUBettype INT = 3
		,@1X2Bettype INT = 5
		,@Handicap1stBettype INT = 7
		,@OU1stBettype INT = 8
		,@1X21stBettype INT = 15
		,@LA1HBettype INT = - 1001
		,@LA2HBettype INT = - 1002
		-- Assignment
		,@TraderType INT = 1
		,@OtherTimeType INT = 2
		,@ETPKType INT = 3
		,@StandbyType INT = 4
		-- Message
		,@MessageInsertAssignment NVARCHAR(MAX)
		,@MessageDeleteAssignment NVARCHAR(MAX)
		,@MessageMatchStatus NVARCHAR(MAX)
		,@MessageInsertAssignmentId INT
		,@MessageDeleteAssignmentId INT
		,@MessageMatchStatusId INT
		-- RefResource
		,@NewAgent NVARCHAR(MAX) = ''
		,@NewProvider NVARCHAR(MAX) = ''
		,@NewRunner NVARCHAR(MAX) = ''
		,@RefName VARCHAR(30)
		-- send message by condition date
		,@FromTimeSendMessage DATETIME
		,@ToTimeSendMessage DATETIME
		,@FromTimeSendMessageSpecialBettype DATETIME
		,@ToTimeSendMessageSpecialBettype DATETIME
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@NextCornerId INT = - 4
		,@NextBookingId INT = - 7
		,@NoOfCorners INT = - 3
		,@TotalBooking INT = - 6
		,@Specific15MinsNoOfCorners INT = - 5
		,@Specific15MinsTotalBooking INT = - 8
		-- Match Status
		,@str_Live NVARCHAR(15) = 'Live'
		,@str_Cancel NVARCHAR(15) = 'Cancel'
		,@str_Postponed NVARCHAR(15) = 'Postponed'
		,@str_Suspended NVARCHAR(15) = 'Suspended'

	IF EXISTS (
			SELECT 1
			FROM dbo.AssignmentUploadingResult WITH (NOLOCK)
			WHERE SessionId = @SessionId
				AND ResultType = 1
			)
	BEGIN
		SELECT @ErrCode = 1
			,@ErrMsg = 'Uploading Fail'

		RETURN
	END

	UPDATE dbo.AssignmentUploadingLog WITH (ROWLOCK, UPDLOCK)
	SET [Status] = 4 -- submit
		,EndDate = GETDATE()
	WHERE SessionId = @SessionId
		AND [Status] = 3 -- Validated

	CREATE TABLE #tblMatches (
		RowNumber INT
		,EventDate DATETIME
		,OWPLeagueId INT
		,League NVARCHAR(4000)
		,OWPHomeId INT
		,Home NVARCHAR(400)
		,OWPAwayId INT
		,Away NVARCHAR(400)
		,MatchNo VARCHAR(50)
		,KickOffTime TIME(7)
		,OtherTime TIME(7)
		,TV NVARCHAR(500)
		,Channel NVARCHAR(100)
		,WB NVARCHAR(100)
		,Agent NVARCHAR(100)
		,Provider NVARCHAR(100)
		,Runner NVARCHAR(100)
		,Phone NVARCHAR(50)
		,Note NVARCHAR(MAX)
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
		,StandbyHDP NVARCHAR(200)
		,OtherTimeHDP NVARCHAR(200)
		,ETPKHDP NVARCHAR(200)
		,Trader1HHDP NVARCHAR(200)
		,Standby1HHDP NVARCHAR(200)
		,OtherTime1HHDP NVARCHAR(200)
		,TraderOU NVARCHAR(200)
		,StandbyOU NVARCHAR(200)
		,OtherTimeOU NVARCHAR(200)
		,ETPKOU NVARCHAR(200)
		,Trader1HOU NVARCHAR(200)
		,Standby1HOU NVARCHAR(200)
		,OtherTime1HOU NVARCHAR(200)
		,Trader1X2 NVARCHAR(200)
		,Standby1X2 NVARCHAR(200)
		,OtherTime1X2 NVARCHAR(200)
		,Trader1H1X2 NVARCHAR(200)
		,Standby1H1X2 NVARCHAR(200)
		,OtherTime1H1X2 NVARCHAR(200)
		,LA1H NVARCHAR(200)
		,Standby1HLA NVARCHAR(200)
		,OtherTime1HLA NVARCHAR(200)
		,ETPK1HLA NVARCHAR(200)
		,LA2H NVARCHAR(200)
		,Standby2HLA NVARCHAR(200)
		,OtherTime2HLA NVARCHAR(200)
		,ETPK2HLA NVARCHAR(200)
		,FM NVARCHAR(200)
		,AIO NVARCHAR(200)
		,EventDateTime DATETIME
		,MatchStatus NVARCHAR(15)
		,[Round] NVARCHAR(2000)
		,OutSide NVARCHAR(2000)
		,Remark NVARCHAR(2000)
		,NoOfHDP NVARCHAR(20)
		,MatchOffer NVARCHAR(50)
		,Website NVARCHAR(1000)
		,Website2 NVARCHAR(1000)
		,Website3 NVARCHAR(1000)
		,Website4 NVARCHAR(1000)
		)

	CREATE TABLE #tblOldMatchInfo (
		OWPMatchId INT
		,MatchNo VARCHAR(50)
		,EventDate DATETIME
		,KickOffTime TIME(7)
		,OtherTime TIME(7)
		,OWPLeagueId INT
		,OWPHomeId INT
		,OWPAwayId INT
		,TVCode NVARCHAR(500)
		,Channel NVARCHAR(100)
		,WatchBet NVARCHAR(100)
		,Phone NVARCHAR(50)
		,KOTimeRemark NVARCHAR(50)
		,IsSelected BIT
		,SelectedBy INT
		,MatchStatus NVARCHAR(15)
		,[Round] NVARCHAR(2000)
		,IsSoloMatch BIT
		,OutSide NVARCHAR(2000)
		,ExtraTimeRemark NVARCHAR(100)
		,Venue NVARCHAR(100)
		,LocalTV NVARCHAR(100)
		,LiveTV NVARCHAR(100)
		,Agent NVARCHAR(100)
		,Provider NVARCHAR(100)
		,Runner NVARCHAR(100)
		,Remark NVARCHAR(2000)
		,NoOfHDP NVARCHAR(20)
		,Website NVARCHAR(1000)
		,Website2 NVARCHAR(1000)
		,Website3 NVARCHAR(1000)
		,Website4 NVARCHAR(1000)
		)

	CREATE TABLE #tblLogs (
		CreatorId INT
		,LoggedDate DATETIME
		,Duration INT
		,ObjectId INT
		,ActionId INT
		,Data NVARCHAR(MAX)
		,DataOld NVARCHAR(MAX)
		)

	CREATE TABLE #tblMatchIds (
		RowNumber INT
		,OWPMatchId INT
		,IsUpdated BIT
		)

	CREATE TABLE #tblRemoveMatchIds (OWPMatchId INT)

	CREATE TABLE #tblRefResource (
		OWPMatchId INT
		,RefName VARCHAR(30)
		,ResourceId SMALLINT
		,Value NVARCHAR(400)
		)

	CREATE TABLE #tblNewRefResourceIds (
		OWPMatchId INT
		,RefName VARCHAR(50)
		,Value NVARCHAR(MAX)
		)

	CREATE TABLE #tblOldMatchNote (
		OWPMatchId INT
		,Note NVARCHAR(MAX)
		)

	CREATE TABLE #tblMatchNote (
		OWPMatchId INT
		,Note NVARCHAR(MAX)
		)

	CREATE TABLE #tblOldRefResourceValues (
		OWPMatchId INT
		,RefName VARCHAR(50)
		,Value NVARCHAR(MAX)
		)

	CREATE TABLE #tblOldMatchSetting (
		OWPMatchId INT
		,BetTypeId INT
		,MaxBet MONEY
		,Spread SMALLMONEY
		)

	CREATE TABLE #tblMatchSetting (
		OWPMatchId INT
		,BetTypeId INT
		,MaxBet MONEY
		,Spread SMALLMONEY
		)

	CREATE TABLE #tblAssignment (
		OWPMatchId INT
		,BetTypeId INT
		,AssignmentType INT
		,UserId INT
		,Username NVARCHAR(50)
		)

	CREATE TABLE #tblOldAssignment (
		OWPMatchId INT
		,BetTypeId INT
		,AssignmentType INT
		,UserId INT
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

	CREATE TABLE #tblMessageMatchCancelled (
		MessageId INT
		,MessageContent NVARCHAR(MAX)
		,MessageTypeId INT
		)

	BEGIN TRY
		INSERT INTO #tblMatches (
			RowNumber
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
			,Provider
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
			,StandbyHDP
			,OtherTimeHDP
			,ETPKHDP
			,Trader1HHDP
			,Standby1HHDP
			,OtherTime1HHDP
			,TraderOU
			,StandbyOU
			,OtherTimeOU
			,ETPKOU
			,Trader1HOU
			,Standby1HOU
			,OtherTime1HOU
			,Trader1X2
			,Standby1X2
			,OtherTime1X2
			,Trader1H1X2
			,Standby1H1X2
			,OtherTime1H1X2
			,LA1H
			,Standby1HLA
			,OtherTime1HLA
			,ETPK1HLA
			,LA2H
			,Standby2HLA
			,OtherTime2HLA
			,ETPK2HLA
			,FM
			,AIO
			,EventDateTime
			,MatchStatus
			,[Round]
			,OutSide
			,Remark
			,NoOfHDP
			,MatchOffer
			,Website
			,Website2
			,Website3
			,Website4
			)
		SELECT au.RowNumber
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
			,ISNULL(au.Provider, '')
			,ISNULL(au.Runner, '')
			,ISNULL(au.Phone, '')
			,ISNULL(au.Note, '')
			,CASE 
				WHEN au.MaxBetHDP = '' THEN NULL
				ELSE CASE 
						WHEN ISNUMERIC(au.MaxBetHDP) = 1 THEN CAST(au.MaxBetHDP AS MONEY)
						ELSE - 1
						END
				END
			,CASE 
				WHEN au.SpreadHDP = '' THEN NULL
				ELSE CASE 
						WHEN ISNUMERIC(au.SpreadHDP) = 1 THEN CAST(au.SpreadHDP AS SMALLMONEY)
						ELSE - 1
						END
				END
			,CASE 
				WHEN au.MaxBet1HHDP = '' THEN NULL
				ELSE CASE 
						WHEN ISNUMERIC(au.MaxBet1HHDP) = 1 THEN CAST(au.MaxBet1HHDP AS MONEY)
						ELSE - 1
						END
				END
			,CASE 
				WHEN au.Spread1HHDP = '' THEN NULL
				ELSE CASE 
						WHEN ISNUMERIC(au.Spread1HHDP) = 1 THEN CAST(au.Spread1HHDP AS SMALLMONEY)
						ELSE - 1
						END
				END
			,CASE 
				WHEN au.MaxBetOU = '' THEN NULL
				ELSE CASE 
						WHEN ISNUMERIC(au.MaxBetOU) = 1 THEN CAST(au.MaxBetOU AS MONEY)
						ELSE - 1
						END
				END
			,CASE 
				WHEN au.SpreadOU = '' THEN NULL
				ELSE CASE 
						WHEN ISNUMERIC(au.SpreadOU) = 1 THEN CAST(au.SpreadOU AS SMALLMONEY)
						ELSE - 1
						END
				END
			,CASE 
				WHEN au.MaxBet1HOU = '' THEN NULL
				ELSE CASE 
						WHEN ISNUMERIC(au.MaxBet1HOU) = 1 THEN CAST(au.MaxBet1HOU AS MONEY)
						ELSE - 1
						END
				END
			,CASE 
				WHEN au.Spread1HOU = '' THEN NULL
				ELSE CASE 
						WHEN ISNUMERIC(au.Spread1HOU) = 1 THEN CAST(au.Spread1HOU AS SMALLMONEY)
						ELSE - 1
						END
				END
			,CASE 
				WHEN au.MaxBet1X2 = '' THEN NULL
				ELSE CASE 
						WHEN ISNUMERIC(au.MaxBet1X2) = 1 THEN CAST(au.MaxBet1X2 AS MONEY)
						ELSE - 1
						END
				END
			,CASE 
				WHEN au.Spread1X2 = '' THEN NULL
				ELSE CASE 
						WHEN ISNUMERIC(au.Spread1X2) = 1 THEN CAST(au.Spread1X2 AS SMALLMONEY)
						ELSE - 1
						END
				END
			,CASE 
				WHEN au.MaxBet1H1X2 = '' THEN NULL
				ELSE CASE 
						WHEN ISNUMERIC(au.MaxBet1H1X2) = 1 THEN CAST(au.MaxBet1H1X2 AS MONEY)
						ELSE - 1
						END
				END
			,CASE 
				WHEN au.Spread1H1X2 = '' THEN NULL
				ELSE CASE 
						WHEN ISNUMERIC(au.Spread1H1X2) = 1 THEN CAST(au.Spread1H1X2 AS SMALLMONEY)
						ELSE - 1
						END
				END
			,au.TraderHDP
			,au.StandbyHDP
			,au.OtherTimeHDP
			,au.ETPKHDP
			,au.Trader1HHDP
			,au.Standby1HHDP
			,au.OtherTime1HHDP
			,au.TraderOU
			,au.StandbyOU
			,au.OtherTimeOU
			,au.ETPKOU
			,au.Trader1HOU
			,au.Standby1HOU
			,au.OtherTime1HOU
			,au.Trader1X2
			,au.Standby1X2
			,au.OtherTime1X2
			,au.Trader1H1X2
			,au.Standby1H1X2
			,au.OtherTime1H1X2
			,au.LA1H
			,au.Standby1HLA
			,au.OtherTime1HLA
			,au.ETPK1HLA
			,au.LA2H
			,au.Standby2HLA
			,au.OtherTime2HLA
			,au.ETPK2HLA
			,au.FM
			,au.AIO
			,DATEADD(DAY, DATEDIFF(DAY, 0, EventDate), CAST(KickOffTime AS DATETIME))
			,au.MatchStatus
			,au.[Round]
			,au.OutSide
			,au.Remark
			,au.NoHDP
			,au.MatchOffer
			,au.Website
			,au.Website2
			,au.Website3
			,au.Website4
		FROM dbo.AssignmentUploading AS au WITH (NOLOCK)
		WHERE SessionId = @SessionId

		-- Insert Home & Away Team
		INSERT INTO dbo.OWPTeam (OWPTeamName)
		OUTPUT @UserId
			,GETDATE()
			,inserted.OWPTeamId
			,7
			,@Duration
			,'<r><z tn="' + inserted.OWPTeamName + '"/></r>'
		INTO #tblLogs(CreatorId, LoggedDate, ObjectId, ActionId, Duration, Data)
		SELECT DISTINCT Home
		FROM #tblMatches AS ass WITH (NOLOCK)
		WHERE NOT EXISTS (
				SELECT 1
				FROM dbo.OWPTeam WITH (NOLOCK)
				WHERE OWPTeamName = ass.Home
				)
		
		UNION
		SELECT DISTINCT Away
		FROM #tblMatches AS ass WITH (NOLOCK)
		WHERE NOT EXISTS (
				SELECT 1
				FROM dbo.OWPTeam WITH (NOLOCK)
				WHERE OWPTeamName = ass.Away
				)

		-- Insert League
		INSERT INTO dbo.OWPLeague (
			OWPLeagueName
			,IsActive
			)
		OUTPUT @UserId
			,GETDATE()
			,inserted.OWPLeagueId
			,4
			,@Duration
			,'<r><z ln="' + inserted.OWPLeagueName + '"/></r>'
		INTO #tblLogs(CreatorId, LoggedDate, ObjectId, ActionId, Duration, Data)
		SELECT DISTINCT League
			,1
		FROM #tblMatches AS ass WITH (NOLOCK)
		WHERE NOT EXISTS (
				SELECT 1
				FROM dbo.OWPLeague WITH (NOLOCK)
				WHERE OWPLeagueName = ass.League
				)

		PRINT 'RefResource'
		PRINT DATEDIFF(MILLISECOND, @FromTime, GETDATE())

		SELECT @NewAgent = @NewAgent + REPLACE(Agent, '/', ',') + ','
		FROM #tblMatches WITH (NOLOCK)

		EXEC dbo.OWP_RefResourceCheckExistsInsert @ListValue = @NewAgent
			,@RefName = 'Agent'

		SELECT @NewProvider = @NewProvider + REPLACE(Provider, '/', ',') + ','
		FROM #tblMatches WITH (NOLOCK)

		EXEC dbo.OWP_RefResourceCheckExistsInsert @ListValue = @NewProvider
			,@RefName = 'Provider'

		SELECT @NewRunner = @NewRunner + REPLACE(Runner, '/', ',') + ','
		FROM #tblMatches WITH (NOLOCK)

		EXEC dbo.OWP_RefResourceCheckExistsInsert @ListValue = @NewRunner
			,@RefName = 'Runner'

		PRINT 'End RefResource'
		PRINT DATEDIFF(MILLISECOND, @FromTime, GETDATE())

		-- Televition
		INSERT INTO dbo.Television (
			TVCode
			,IsActive
			)
		SELECT DISTINCT CAST(RTRIM(LTRIM(Split.val)) AS NVARCHAR(500)) AS Value
			,1
		FROM (
			SELECT TV
			FROM #tblMatches WITH (NOLOCK)
			) AS pvd
			CROSS APPLY dbo.fnc_SplitStrings(REPLACE(TV, '/', ','), ',') AS Split
		WHERE RTRIM(LTRIM(Split.val)) <> ''
			AND NOT EXISTS (
				SELECT 1
				FROM dbo.Television WITH (NOLOCK)
				WHERE TVCode = RTRIM(LTRIM(Split.val))
				)

		PRINT 'insert Match'
		PRINT DATEDIFF(MILLISECOND, @FromTime, GETDATE())

		INSERT INTO #tblMatchIds (
			RowNumber
			,OWPMatchId
			,IsUpdated
			)
		SELECT ass.RowNumber
			,ma.OWPMatchId
			,1
		FROM #tblMatches AS ass WITH (NOLOCK)
			INNER JOIN dbo.OWPTeam AS ht WITH (NOLOCK) ON ass.Home = ht.OWPTeamName
			INNER JOIN dbo.OWPTeam AS at WITH (NOLOCK) ON ass.Away = at.OWPTeamName
			INNER JOIN dbo.OWPLeague AS lea WITH (NOLOCK) ON ass.League = lea.OWPLeagueName
			INNER JOIN dbo.OWPMatch AS ma WITH (NOLOCK) ON ma.EventDate = ass.EventDate
			AND ma.OWPLeagueId = lea.OWPLeagueId
			AND ma.OWPHomeId = ht.OWPTeamId
			AND ma.OWPAwayId = at.OWPTeamId

		MERGE dbo.OWPMatch AS ma
		USING (
			SELECT MatchNo
				,EventDate
				,KickOffTime
				,ass.OtherTime
				,ass.EventDateTime
				,lea.OWPLeagueId
				,ht.OWPTeamId AS HomeTeamId
				,at.OWPTeamId AS AwayTeamId
				,ass.RowNumber
			FROM #tblMatches AS ass WITH (NOLOCK)
				INNER JOIN dbo.OWPTeam AS ht WITH (NOLOCK) ON ass.Home = ht.OWPTeamName
				INNER JOIN dbo.OWPTeam AS at WITH (NOLOCK) ON ass.Away = at.OWPTeamName
				INNER JOIN dbo.OWPLeague AS lea WITH (NOLOCK) ON ass.League = lea.OWPLeagueName
			WHERE NOT EXISTS (
					SELECT 1
					FROM dbo.OWPMatch WITH (NOLOCK)
					WHERE EventDate = ass.EventDate
						AND OWPLeagueId = lea.OWPLeagueId
						AND OWPHomeId = ht.OWPTeamId
						AND OWPAwayId = at.OWPTeamId
					)
			) AS mat ON 1 = 0
		WHEN NOT MATCHED THEN
				INSERT (
					MatchNo
					,EventDate
					,KickOffTime
					,OtherTime
					,EventDateTime
					,OWPLeagueId
					,OWPHomeId
					,OWPAwayId
					)
				VALUES (
					MatchNo
					,EventDate
					,KickOffTime
					,OtherTime
					,EventDateTime
					,OWPLeagueId
					,HomeTeamId
					,AwayTeamId
					)
		OUTPUT mat.RowNumber
			,inserted.OWPMatchId
			,0
		INTO #tblMatchIds(RowNumber, OWPMatchId, IsUpdated);

		SELECT TOP 1 @EventDate = CASE 
				WHEN CAST(KickOffTime AS TIME) >= CAST('12:00:00' AS TIME) THEN EventDate
				ELSE DATEADD(DD, - 1, EventDate)
				END
		FROM dbo.AssignmentUploading WITH (NOLOCK)
		WHERE SessionId = @SessionId

		INSERT INTO #tblRemoveMatchIds (OWPMatchId)
		SELECT mat.OWPMatchId
		FROM dbo.OWPMatch AS mat WITH (NOLOCK)
		WHERE (
				(
					mat.EventDate = @EventDate
					AND mat.KickOffTime >= CAST('12:00:00' AS TIME)
					)
				OR (
					mat.EventDate = DATEADD(DD, 1, @EventDate)
					AND mat.KickOffTime < CAST('12:00:00' AS TIME)
					)
				)
			AND NOT EXISTS (
				SELECT 1
				FROM #tblMatchIds WITH (NOLOCK)
				WHERE OWPMatchId = mat.OWPMatchId
				)

		INSERT INTO #tblOldMatchInfo (
			OWPMatchId
			,MatchNo
			,EventDate
			,KickOffTime
			,OtherTime
			,OWPLeagueId
			,OWPHomeId
			,OWPAwayId
			,TVCode
			,Channel
			,WatchBet
			,Phone
			,KOTimeRemark
			,IsSelected
			,SelectedBy
			,MatchStatus
			,[Round]
			,IsSoloMatch
			,OutSide
			,ExtraTimeRemark
			,Venue
			,LocalTV
			,LiveTV
			,Agent
			,Provider
			,Runner
			,Remark
			,NoOfHDP
			,Website
			,Website2
			,Website3
			,Website4
			)
		SELECT ma.OWPMatchId
			,ma.MatchNo
			,ma.EventDate
			,ma.KickOffTime
			,ma.OtherTime
			,ma.OWPLeagueId
			,ma.OWPHomeId
			,ma.OWPAwayId
			,mif.TVCode
			,mif.Channel
			,mif.WatchBet
			,mif.Phone
			,mif.KOTimeRemark
			,mif.IsSelected
			,mif.SelectedBy
			,mif.MatchStatus
			,mif.[Round]
			,mif.IsSoloMatch
			,mif.OutSide
			,mif.ExtraTimeRemark
			,mif.Venue
			,mif.LocalTV
			,mif.LiveTV
			,mif.Agent
			,mif.Provider
			,mif.Runner
			,mif.Remark
			,mif.NoOfHDP
			,mif.Website
			,mif.Website2
			,mif.Website3
			,mif.Website4
		FROM #tblMatchIds AS mat WITH (NOLOCK)
			INNER JOIN dbo.OWPMatch AS ma WITH (NOLOCK) ON mat.OWPMatchId = ma.OWPMatchId
			INNER JOIN dbo.MatchInfo AS mif WITH (NOLOCK) ON mat.OWPMatchId = mif.OWPMatchId
		WHERE mat.IsUpdated = 1

		UPDATE ma
		SET ma.KickOffTime = asm.KickOffTime
			,ma.MatchNo = asm.MatchNo
			,ma.EventDateTime = asm.EventDateTime
			,ma.OtherTime = asm.OtherTime
		FROM dbo.OWPMatch AS ma WITH (ROWLOCK)
			INNER JOIN #tblMatchIds AS mat WITH (NOLOCK) ON ma.OWPMatchId = mat.OWPMatchId
			AND mat.IsUpdated = 1
			INNER JOIN #tblMatches AS asm WITH (NOLOCK) ON mat.RowNumber = asm.RowNumber
		--WHERE ma.KickOffTime <> asm.KickOffTime
		--	OR ISNULL(ma.MatchNo, '') <> ISNULL(asm.MatchNo, '')
		--	OR ISNULL(ma.OtherTime, '') <> asm.OtherTime

		PRINT 'end insert owp Match'
		PRINT DATEDIFF(MILLISECOND, @FromTime, GETDATE())

		-- RefResource
		INSERT INTO #tblRefResource (
			OWPMatchId
			,RefName
			,ResourceId
			,Value
			)
		SELECT ma.OWPMatchId
			,rs.RefName
			,rs.ResourceId
			,ag.val
		FROM #tblMatchIds AS ma WITH (NOLOCK)
			INNER JOIN #tblMatches AS asm WITH (NOLOCK) ON ma.RowNumber = asm.RowNumber
			CROSS APPLY dbo.fnc_SplitStrings(REPLACE(asm.Agent, '/', ','), ',') AS ag
			INNER JOIN dbo.RefResource AS rs WITH (NOLOCK) ON ag.val = rs.Value
			AND rs.RefName = 'Agent'
		
		UNION
		SELECT ma.OWPMatchId
			,rs.RefName
			,rs.ResourceId
			,pv.val
		FROM #tblMatchIds AS ma WITH (NOLOCK)
			INNER JOIN #tblMatches AS asm WITH (NOLOCK) ON ma.RowNumber = asm.RowNumber
			CROSS APPLY dbo.fnc_SplitStrings(REPLACE(asm.Provider, '/', ','), ',') AS pv
			INNER JOIN dbo.RefResource AS rs WITH (NOLOCK) ON pv.val = rs.Value
			AND rs.RefName = 'Provider'
		
		UNION
		SELECT ma.OWPMatchId
			,rs.RefName
			,rs.ResourceId
			,rn.val
		FROM #tblMatchIds AS ma WITH (NOLOCK)
			INNER JOIN #tblMatches AS asm WITH (NOLOCK) ON ma.RowNumber = asm.RowNumber
			CROSS APPLY dbo.fnc_SplitStrings(REPLACE(asm.Runner, '/', ','), ',') AS rn
			INNER JOIN dbo.RefResource AS rs WITH (NOLOCK) ON rn.val = rs.Value
			AND rs.RefName = 'Runner'
		OPTION (MAXRECURSION 0)

		INSERT INTO #tblNewRefResourceIds (
			OWPMatchId
			,RefName
			,Value
			)
		SELECT OWPMatchId
			,RefName
			,STUFF((
					SELECT ',' + CAST(ResourceId AS VARCHAR(10))
					FROM #tblRefResource WITH (NOLOCK)
					WHERE OWPMatchId = t.OWPMatchId
						AND RefName = t.RefName
					FOR XML path('')
					), 1, 1, '')
		FROM (
			SELECT DISTINCT OWPMatchId
				,RefName
			FROM #tblRefResource WITH (NOLOCK)
			) t

		PRINT 'Ref'
		PRINT DATEDIFF(MILLISECOND, @FromTime, GETDATE())

		UPDATE ma
		SET ma.TVCode = REPLACE(asm.TV, '/', ',')
			,ma.Channel = asm.Channel
			,ma.WatchBet = asm.WB
			,ma.Provider = pv.Value
			,ma.Runner = ru.Value
			,ma.Phone = asm.Phone
			,ma.IsSelected = 1
			,ma.SelectedBy = @UserId
			,ma.MatchStatus = asm.MatchStatus
			,ma.Agent = ag.Value
			,ma.IsSelectedUpdatedDate = GETDATE()
			,ma.[Round] = asm.[Round]
			,ma.OutSide = asm.OutSide
			,ma.Remark = asm.Remark
			,ma.NoOfHDP = asm.NoOfHDP
			,ma.KOTimeRemark = asm.MatchOffer
			,ma.Website = asm.Website
			,ma.Website2 = asm.Website2
			,ma.Website3 = asm.Website3
			,ma.Website4 = asm.Website4
		FROM dbo.MatchInfo AS ma WITH (ROWLOCK)
			INNER JOIN #tblMatchIds AS mat WITH (NOLOCK) ON ma.OWPMatchId = mat.OWPMatchId
			AND mat.IsUpdated = 1
			INNER JOIN #tblMatches AS asm WITH (NOLOCK) ON mat.RowNumber = asm.RowNumber
			LEFT JOIN #tblNewRefResourceIds AS pv WITH (NOLOCK) ON mat.OWPMatchId = pv.OWPMatchId
			AND pv.RefName = 'Provider'
			LEFT JOIN #tblNewRefResourceIds AS ru WITH (NOLOCK) ON mat.OWPMatchId = ru.OWPMatchId
			AND ru.RefName = 'Runner'
			LEFT JOIN #tblNewRefResourceIds AS ag WITH (NOLOCK) ON mat.OWPMatchId = ag.OWPMatchId
			AND ag.RefName = 'Agent'

		UPDATE ma
		SET ma.MatchNo = ''
		FROM dbo.OWPMatch AS ma WITH (ROWLOCK)
			INNER JOIN #tblRemoveMatchIds AS mat WITH (NOLOCK) ON ma.OWPMatchId = mat.OWPMatchId

		UPDATE ma
		SET ma.IsSelected = 0
			,ma.SelectedBy = @UserId
			,ma.IsSelectedUpdatedDate = GETDATE()
		FROM dbo.MatchInfo AS ma WITH (ROWLOCK)
			INNER JOIN #tblRemoveMatchIds AS mat WITH (NOLOCK) ON ma.OWPMatchId = mat.OWPMatchId

		INSERT INTO dbo.MatchInfo (
			[OWPMatchId]
			,[TVCode]
			,[Channel]
			,[WatchBet]
			,[Provider]
			,[Runner]
			,[Phone]
			,[IsSelected]
			,[SelectedBy]
			,[MatchStatus]
			,[Agent]
			,[IsSelectedUpdatedDate]
			,[IsSoloMatch]
			,[Round]
			,OutSide
			,Remark
			,NoOfHDP
			,KOTimeRemark
			,Website
			,Website2
			,Website3
			,Website4
			)
		SELECT ma.OWPMatchId
			,REPLACE(ass.TV, '/', ',')
			,ass.Channel
			,ass.WB
			,pv.Value
			,ru.Value
			,ass.Phone
			,1
			,@UserId
			,ass.MatchStatus
			,ag.Value
			,GETDATE()
			,0
			,ass.[Round]
			,ass.OutSide
			,ass.Remark
			,ass.NoOfHDP
			,ass.MatchOffer
			,ass.Website
			,ass.Website2
			,ass.Website3
			,ass.Website4
		FROM #tblMatches AS ass WITH (NOLOCK)
			INNER JOIN #tblMatchIds AS ma WITH (NOLOCK) ON ass.RowNumber = ma.RowNumber
			AND ma.IsUpdated = 0
			LEFT JOIN #tblNewRefResourceIds AS pv WITH (NOLOCK) ON ma.OWPMatchId = pv.OWPMatchId
			AND pv.RefName = 'Provider'
			LEFT JOIN #tblNewRefResourceIds AS ru WITH (NOLOCK) ON ma.OWPMatchId = ru.OWPMatchId
			AND ru.RefName = 'Runner'
			LEFT JOIN #tblNewRefResourceIds AS ag WITH (NOLOCK) ON ma.OWPMatchId = ag.OWPMatchId
			AND ag.RefName = 'Agent'

		PRINT 'end Match Info'
		PRINT DATEDIFF(MILLISECOND, @FromTime, GETDATE())

		-- Determine Minor Match
				EXEC dbo.OWP_MinorMatchAutoDetermine

		-- update cancel status for minor match when parent match cancelled
		UPDATE minfo
		SET minfo.MatchStatus = pinfo.MatchStatus
		FROM dbo.MatchInfo AS minfo WITH (ROWLOCK)
			INNER JOIN #tblMatchIds AS mm WITH (NOLOCK) ON minfo.OWPMatchId = mm.OWPMatchId
			INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON minfo.OWPMatchId = minor.MinorMatchId
			INNER JOIN dbo.MatchInfo AS pinfo WITH (NOLOCK) ON minor.ParentMatchId = pinfo.OWPMatchId
						AND pinfo.MatchStatus IN (@str_Cancel, @str_Suspended, @str_Postponed)
			INNER JOIN #tblMatchIds AS pm WITH (NOLOCK) ON pinfo.OWPMatchId = pm.OWPMatchId
			LEFT JOIN dbo.MinorMatch AS pminor WITH (NOLOCK) ON pinfo.OWPMatchId = pminor.MinorMatchId
		WHERE pminor.MinorMatchId IS NULL

		INSERT INTO #tblOldMatchNote (
			OWPMatchId
			,Note
			)
		SELECT ma.OWPMatchId
			,stuff((
					SELECT '@#' + Note
					FROM (
						SELECT mat.RowNumber
							,nt.Note
						FROM dbo.MatchNote AS nt WITH (NOLOCK)
							INNER JOIN #tblMatchIds AS mat WITH (NOLOCK) ON nt.OWPMatchId = mat.OWPMatchId
						) AS nv
					WHERE RowNumber = ma.RowNumber
					FOR XML path('')
					), 1, 1, '') AS Note
		FROM #tblMatchIds AS ma WITH (NOLOCK)

		PRINT 'log old note'
		PRINT DATEDIFF(MILLISECOND, @FromTime, GETDATE())

		MERGE dbo.MatchNote AS mn1
		USING (
			SELECT OWPMatchId
				,Value
			FROM (
				SELECT OWPMatchId
					,RTRIM(LTRIM(Split.val)) AS Value
				FROM (
					SELECT mat.RowNumber
						,mat.OWPMatchId
						,asm.Note
					FROM #tblMatchIds AS mat WITH (NOLOCK)
						INNER JOIN #tblMatches AS asm WITH (NOLOCK) ON mat.RowNumber = asm.RowNumber
					) AS mn
					CROSS APPLY dbo.fnc_SplitStrings(Note, '@#') AS Split
				) AS t
			WHERE ISNULL(t.Value, '') <> ''
			) AS mn2 ON mn1.OWPMatchId = mn2.OWPMatchId
				AND mn1.Note = mn2.Value
		WHEN NOT MATCHED THEN
				INSERT (
					[OWPMatchId]
					,[CreatedDate]
					,[CreatedBy]
					,[Note]
					)
				VALUES (
					mn2.OWPMatchId
					,GETDATE()
					,@UserId
					,mn2.Value
					)
		OUTPUT inserted.CreatedBy
			,inserted.CreatedDate
			,inserted.MatchNoteId
			,10
			,0
			,'<r><z mt="' + CAST(mn2.OWPMatchId AS VARCHAR(10)) + '" nt="' + inserted.Note + '"/></r>'
		INTO #tblLogs(CreatorId, LoggedDate, ObjectId, ActionId, Duration, Data);

		PRINT 'end insert Match Note'
		PRINT DATEDIFF(MILLISECOND, @FromTime, GETDATE())

		INSERT INTO #tblMatchNote (
			OWPMatchId
			,Note
			)
		SELECT ma.OWPMatchId
			,stuff((
					SELECT '@#' + Note
					FROM (
						SELECT mat.RowNumber
							,nt.Note
						FROM dbo.MatchNote AS nt WITH (NOLOCK)
							INNER JOIN #tblMatchIds AS mat WITH (NOLOCK) ON nt.OWPMatchId = mat.OWPMatchId
						) AS nv
					WHERE RowNumber = ma.RowNumber
					FOR XML path('')
					), 1, 1, '') AS Note
		FROM #tblMatchIds AS ma WITH (NOLOCK)

		PRINT 'end Match Note log'
		PRINT DATEDIFF(MILLISECOND, @FromTime, GETDATE())

		-- Old Agent, Provider, Runner
		TRUNCATE TABLE #tblRefResource

		INSERT INTO #tblRefResource (
			OWPMatchId
			,RefName
			,ResourceId
			,Value
			)
		SELECT inf.OWPMatchId
			,rs.RefName
			,rs.ResourceId
			,rs.Value
		FROM #tblOldMatchInfo AS inf WITH (NOLOCK)
			CROSS APPLY dbo.fnc_SplitStrings(inf.Agent, ',') AS ag
			INNER JOIN RefResource AS rs WITH (NOLOCK) ON ag.val = rs.ResourceId
			AND rs.RefName = 'Agent'
		
		UNION
		SELECT inf.OWPMatchId
			,rs.RefName
			,rs.ResourceId
			,rs.Value
		FROM #tblOldMatchInfo AS inf WITH (NOLOCK)
			CROSS APPLY dbo.fnc_SplitStrings(inf.Provider, ',') AS pv
			INNER JOIN RefResource AS rs WITH (NOLOCK) ON pv.val = rs.ResourceId
			AND rs.RefName = 'Provider'
		
		UNION
		SELECT inf.OWPMatchId
			,rs.RefName
			,rs.ResourceId
			,rs.Value
		FROM #tblOldMatchInfo AS inf WITH (NOLOCK)
			CROSS APPLY dbo.fnc_SplitStrings(inf.Runner, ',') AS rn
			INNER JOIN RefResource AS rs WITH (NOLOCK) ON rn.val = rs.ResourceId
			AND rs.RefName = 'Runner'
		OPTION (MAXRECURSION 0)

		INSERT INTO #tblOldRefResourceValues (
			OWPMatchId
			,RefName
			,Value
			)
		SELECT OWPMatchId
			,RefName
			,STUFF((
					SELECT ',' + CAST(Value AS VARCHAR(10))
					FROM #tblRefResource WITH (NOLOCK)
					WHERE OWPMatchId = t.OWPMatchId
						AND RefName = t.RefName
					FOR XML path('')
					), 1, 1, '')
		FROM (
			SELECT DISTINCT OWPMatchId
				,RefName
			FROM #tblRefResource WITH (NOLOCK)
			) t

		PRINT 'end Old Agent, Provider, Runner'
		PRINT DATEDIFF(MILLISECOND, @FromTime, GETDATE())

		-- Insert Match log
		INSERT INTO #tblLogs (
			CreatorId
			,LoggedDate
			,ObjectId
			,ActionId
			,Duration
			,Data
			,DataOld
			)
		SELECT @UserId
			,GETDATE()
			,mat.OWPMatchId
			,1
			,@Duration
			,REPLACE(CONVERT(NVARCHAR(MAX), (
						SELECT asm.EventDate AS '@ed'
							,asm.KickOffTime AS '@ko'
							,asm.OtherTime AS '@ot'
							,asm.League AS '@ln'
							,asm.Home AS '@hn'
							,asm.Away AS '@an'
							,mn.Note AS '@nt'
							,inf.TVCode AS '@tv'
							,inf.Channel AS '@ch'
							,inf.WatchBet AS '@wb'
							,asm.Provider AS '@pv'
							,asm.Runner AS '@rn'
							,inf.Phone AS '@ph'
							,inf.KOTimeRemark AS '@kr'
							,inf.IsSelected AS '@is'
							,inf.SelectedBy AS '@sb'
							,inf.MatchStatus AS '@ms'
							,inf.[Round] AS '@rd'
							,inf.IsSoloMatch AS '@sl'
							,inf.OutSide AS '@os'
							,inf.ExtraTimeRemark AS '@et'
							,inf.Venue AS '@vn'
							,inf.LocalTV AS '@lo'
							,inf.LiveTV AS '@li'
							,inf.Website AS '@ws'
							,inf.Agent AS '@ag'
							,inf.Remark AS '@rm'
							,inf.NoOfHDP AS '@nohdp'
							,inf.Website2 AS '@ws2'
							,inf.Website3 AS '@ws3'
							,inf.Website4 AS '@ws4'
						FOR XML PATH('z')
							,ROOT('r')
						)), '" />', '"/"')
			,CASE 
				WHEN oma.OWPMatchId IS NULL THEN NULL
				ELSE REPLACE(CONVERT(NVARCHAR(MAX), (
								SELECT asm.EventDate AS '@ed'
									,oma.KickOffTime AS '@ko'
									,oma.OtherTime AS '@ot'
									,olg.OWPLeagueName AS '@ln'
									,oht.OWPTeamName AS '@hn'
									,oat.OWPTeamName AS '@an'
									,omn.Note AS '@nt'
									,oma.TVCode AS '@tv'
									,oma.Channel AS '@ch'
									,oma.WatchBet AS '@wb'
									,opv.Value AS '@pv'
									,oru.Value AS '@rn'
									,oma.Phone AS '@ph'
									,oma.KOTimeRemark AS '@kr'
									,oma.IsSelected AS '@is'
									,oma.SelectedBy AS '@sb'
									,oma.MatchStatus AS '@ms'
									,oma.[Round] AS '@rd'
									,oma.IsSoloMatch AS '@sl'
									,oma.OutSide AS '@os'
									,oma.ExtraTimeRemark AS '@et'
									,oma.Venue AS '@vn'
									,oma.LocalTV AS '@lo'
									,oma.LiveTV AS '@li'
									,oma.Website AS '@ws'
									,oag.Value AS '@ag'
									,oma.Remark AS '@rm'
									,oma.NoOfHDP AS '@nohdp'
									,inf.Website2 AS '@ws2'
									,inf.Website3 AS '@ws3'
									,inf.Website4 AS '@ws4'
								FOR XML PATH('z')
									,ROOT('r')
								)), '" />', '"/"')
				END
		FROM #tblMatchIds AS mat WITH (NOLOCK)
			INNER JOIN #tblMatches AS asm WITH (NOLOCK) ON mat.RowNumber = asm.RowNumber
			INNER JOIN dbo.MatchInfo AS inf WITH (NOLOCK) ON mat.OWPMatchId = inf.OWPMatchId
			LEFT JOIN #tblOldMatchInfo AS oma WITH (NOLOCK) ON mat.OWPMatchId = oma.OWPMatchId
			LEFT JOIN dbo.OWPLeague AS olg WITH (NOLOCK) ON oma.OWPLeagueId = olg.OWPLeagueId
			LEFT JOIN dbo.OWPTeam AS oht WITH (NOLOCK) ON oma.OWPHomeId = oht.OWPTeamId
			LEFT JOIN dbo.OWPTeam AS oat WITH (NOLOCK) ON oma.OWPAwayId = oat.OWPTeamId
			LEFT JOIN #tblOldRefResourceValues AS oag WITH (NOLOCK) ON mat.OWPMatchId = oag.OWPMatchId
			AND oag.RefName = 'Agent'
			LEFT JOIN #tblOldRefResourceValues AS opv WITH (NOLOCK) ON mat.OWPMatchId = opv.OWPMatchId
			AND opv.RefName = 'Provider'
			LEFT JOIN #tblOldRefResourceValues AS oru WITH (NOLOCK) ON mat.OWPMatchId = oru.OWPMatchId
			AND oru.RefName = 'Runner'
			LEFT JOIN #tblOldMatchNote AS omn WITH (NOLOCK) ON mat.OWPMatchId = omn.OWPMatchId
			LEFT JOIN #tblMatchNote AS mn WITH (NOLOCK) ON mat.OWPMatchId = mn.OWPMatchId
		WHERE oma.OWPMatchId IS NULL
			OR asm.KickOffTime <> oma.KickOffTime
			OR asm.OtherTime <> oma.OtherTime
			OR asm.League <> olg.OWPLeagueName
			OR asm.Home <> oht.OWPTeamName
			OR asm.Away <> oat.OWPTeamName
			OR mn.Note <> omn.Note
			OR inf.TVCode <> oma.TVCode
			OR asm.Agent <> oag.Value
			OR asm.Provider <> opv.Value
			OR asm.Runner <> oru.Value
			OR inf.Channel <> oma.Channel
			OR inf.Phone <> oma.Phone
			OR inf.[Round] <> oma.[Round]
			OR inf.OutSide <> oma.OutSide
			OR inf.Remark <> oma.Remark
			OR inf.Website <> oma.Website
			OR inf.Website2 <> oma.Website2
			OR inf.Website3 <> oma.Website3
			OR inf.Website4 <> oma.Website4

		PRINT 'end Match log'
		PRINT DATEDIFF(MILLISECOND, @FromTime, GETDATE())

		INSERT INTO #tblMatchSetting (
			OWPMatchId
			,BetTypeId
			,MaxBet
			,Spread
			)
		SELECT mat.OWPMatchId
			,@HandicapBettype
			,asm.MaxBetHDP
			,asm.SpreadHDP
		FROM #tblMatches AS asm WITH (NOLOCK)
			INNER JOIN #tblMatchIds AS mat WITH (NOLOCK) ON asm.RowNumber = mat.RowNumber
		
		UNION
		SELECT mat.OWPMatchId
			,@OUBettype
			,asm.MaxBetOU
			,asm.SpreadOU
		FROM #tblMatches AS asm WITH (NOLOCK)
			INNER JOIN #tblMatchIds AS mat WITH (NOLOCK) ON asm.RowNumber = mat.RowNumber
		
		UNION
		SELECT mat.OWPMatchId
			,@1X2Bettype
			,asm.MaxBet1X2
			,asm.Spread1X2
		FROM #tblMatches AS asm WITH (NOLOCK)
			INNER JOIN #tblMatchIds AS mat WITH (NOLOCK) ON asm.RowNumber = mat.RowNumber
		
		UNION
		SELECT mat.OWPMatchId
			,@Handicap1stBettype
			,asm.MaxBet1HHDP
			,asm.Spread1HHDP
		FROM #tblMatches AS asm WITH (NOLOCK)
			INNER JOIN #tblMatchIds AS mat WITH (NOLOCK) ON asm.RowNumber = mat.RowNumber
		
		UNION
		SELECT mat.OWPMatchId
			,@OU1stBettype
			,asm.MaxBet1HOU
			,asm.Spread1HOU
		FROM #tblMatches AS asm WITH (NOLOCK)
			INNER JOIN #tblMatchIds AS mat WITH (NOLOCK) ON asm.RowNumber = mat.RowNumber
		
		UNION
		SELECT mat.OWPMatchId
			,@1X21stBettype
			,asm.MaxBet1H1X2
			,asm.Spread1H1X2
		FROM #tblMatches AS asm WITH (NOLOCK)
			INNER JOIN #tblMatchIds AS mat WITH (NOLOCK) ON asm.RowNumber = mat.RowNumber

		INSERT INTO #tblOldMatchSetting (
			OWPMatchId
			,BetTypeId
			,MaxBet
			,Spread
			)
		SELECT st.OWPMatchId
			,st.Bettype
			,st.Maxbet
			,st.Spread
		FROM dbo.MatchSetting AS st WITH (NOLOCK)
			INNER JOIN #tblMatchSetting AS mst WITH (NOLOCK) ON st.OWPMatchId = mst.OWPMatchId
			AND st.Bettype = mst.BetTypeId

		DELETE st
		FROM dbo.MatchSetting AS st WITH (UPDLOCK)
		WHERE EXISTS (
				SELECT 1
				FROM #tblMatchSetting AS mst WITH (NOLOCK)
				WHERE st.OWPMatchId = mst.OWPMatchId
					AND st.Bettype = mst.BetTypeId
					AND mst.MaxBet IS NULL
					AND mst.Spread IS NULL
				)

		UPDATE st
		SET st.Maxbet = CASE 
				WHEN mst.MaxBet = - 1 THEN st.Maxbet
				ELSE mst.MaxBet
				END
			,st.Spread = CASE 
				WHEN mst.Spread = - 1 THEN st.Spread
				ELSE mst.Spread
				END
		FROM dbo.MatchSetting AS st WITH (ROWLOCK)
			INNER JOIN #tblMatchSetting AS mst WITH (NOLOCK) ON st.OWPMatchId = mst.OWPMatchId
			AND st.Bettype = mst.BetTypeId
		WHERE ISNULL(st.Maxbet, - 2) <> ISNULL(mst.MaxBet, - 2)
			OR ISNULL(st.Spread, - 2) <> ISNULL(mst.Spread, - 2)

		INSERT INTO dbo.MatchSetting (
			OWPMatchId
			,Bettype
			,Maxbet
			,Spread
			)
		SELECT mst.OWPMatchId
			,mst.BetTypeId
			,CASE 
				WHEN mst.MaxBet = - 1 THEN NULL
				ELSE mst.MaxBet
				END
			,CASE 
				WHEN mst.Spread = - 1 THEN NULL
				ELSE mst.Spread
				END
		FROM #tblMatchSetting AS mst WITH (NOLOCK)
		WHERE (
				ISNULL(mst.MaxBet, - 1) <> - 1
				OR ISNULL(mst.Spread, - 1) <> - 1
				)
			AND NOT EXISTS (
				SELECT 1
				FROM dbo.MatchSetting WITH (NOLOCK)
				WHERE OWPMatchId = mst.OWPMatchId
					AND Bettype = mst.BetTypeId
				)

		PRINT 'end Match Setting'
		PRINT DATEDIFF(MILLISECOND, @FromTime, GETDATE())

		-- Log Match Setting
		INSERT INTO #tblLogs (
			CreatorId
			,LoggedDate
			,ObjectId
			,ActionId
			,Duration
			,Data
			,DataOld
			)
		SELECT @UserId
			,GETDATE()
			,ost.OWPMatchId
			,27
			,@Duration
			,REPLACE(CONVERT(NVARCHAR(MAX), (
						SELECT ost.OWPMatchId AS '@mt'
							,ost.BetTypeId AS '@bt'
							,st.Maxbet AS '@mb'
							,st.Spread AS '@sp'
						FOR XML PATH('z')
							,ROOT('r')
						)), '" />', '"/"')
			,REPLACE(CONVERT(NVARCHAR(MAX), (
						SELECT ost.OWPMatchId AS '@mt'
							,ost.BetTypeId AS '@bt'
							,ost.MaxBet AS '@mb'
							,ost.Spread AS '@sp'
						FOR XML PATH('z')
							,ROOT('r')
						)), '" />', '"/"')
		FROM #tblOldMatchSetting AS ost WITH (NOLOCK)
			INNER JOIN dbo.MatchSetting AS st WITH (NOLOCK) ON ost.OWPMatchId = st.OWPMatchId
			AND ost.BetTypeId = st.Bettype
		WHERE st.Maxbet <> ost.MaxBet
			OR st.Spread <> ost.Spread
		
		UNION
		SELECT @UserId
			,GETDATE()
			,mst.OWPMatchId
			,26
			,@Duration
			,REPLACE(CONVERT(NVARCHAR(MAX), (
						SELECT mst.OWPMatchId AS '@mt'
							,mst.BetTypeId AS '@bt'
							,mst.Maxbet AS '@mb'
							,mst.Spread AS '@sp'
						FOR XML PATH('z')
							,ROOT('r')
						)), '" />', '"/"')
			,NULL
		FROM #tblMatchSetting AS mst WITH (NOLOCK)
		WHERE NOT EXISTS (
				SELECT 1
				FROM #tblOldMatchSetting WITH (NOLOCK)
				WHERE OWPMatchId = mst.OWPMatchId
					AND BetTypeId = mst.BetTypeId
				)
		
		UNION
		SELECT @UserId
			,GETDATE()
			,ost.OWPMatchId
			,27
			,@Duration
			,NULL
			,REPLACE(CONVERT(NVARCHAR(MAX), (
						SELECT st.OWPMatchId AS '@mt'
							,st.BetType AS '@bt'
							,st.MaxBet AS '@mb'
							,st.Spread AS '@sp'
						FOR XML PATH('z')
							,ROOT('r')
						)), '" />', '"/"')
		FROM #tblRemoveMatchIds AS ost WITH (NOLOCK)
			INNER JOIN dbo.MatchSetting AS st WITH (NOLOCK) ON ost.OWPMatchId = st.OWPMatchId

		-- delete match setting for match does not exists in upload file
		DELETE st
		FROM dbo.MatchSetting AS st WITH (UPDLOCK)
		WHERE EXISTS (
				SELECT 1
				FROM #tblRemoveMatchIds AS mat WITH (NOLOCK)
				WHERE st.OWPMatchId = mat.OWPMatchId
				)

		PRINT 'end log match setting'
		PRINT DATEDIFF(MILLISECOND, @FromTime, GETDATE())

		INSERT INTO #tblOldAssignment (
			OWPMatchId
			,BetTypeId
			,AssignmentType
			,UserId
			)
		SELECT asg.OWPMatchId
			,asg.BetType
			,asg.AssignmentType
			,asg.UserId
		FROM dbo.Assignment AS asg WITH (NOLOCK)
			INNER JOIN #tblMatchIds AS mat WITH (NOLOCK) ON asg.OWPMatchId = mat.OWPMatchId
		WHERE mat.IsUpdated = 1
		
		UNION
		SELECT asg.OWPMatchId
			,asg.BetType
			,asg.AssignmentType
			,asg.UserId
		FROM dbo.Assignment AS asg WITH (NOLOCK)
			INNER JOIN #tblRemoveMatchIds AS mat WITH (NOLOCK) ON asg.OWPMatchId = mat.OWPMatchId

		INSERT INTO #tblAssignment (
			OWPMatchId
			,BetTypeId
			,AssignmentType
			,Username
			)
		SELECT OWPMatchId
			,BettypeId
			,AssignmentType
			,Trader
		FROM (
			SELECT OWPMatchId
				,CASE 
					WHEN Bettype = 'TraderHDP' THEN 1
					WHEN Bettype = 'StandbyHDP' THEN 1
					WHEN Bettype = 'OtherTimeHDP' THEN 1
					WHEN Bettype = 'ETPKHDP' THEN 1
					WHEN Bettype = 'Trader1HHDP' THEN 7
					WHEN Bettype = 'Standby1HHDP' THEN 7
					WHEN Bettype = 'OtherTime1HHDP' THEN 7
					WHEN Bettype = 'TraderOU' THEN 3
					WHEN Bettype = 'StandbyOU' THEN 3
					WHEN Bettype = 'OtherTimeOU' THEN 3
					WHEN Bettype = 'ETPKOU' THEN 3
					WHEN Bettype = 'Trader1HOU' THEN 8
					WHEN Bettype = 'Standby1HOU' THEN 8
					WHEN Bettype = 'OtherTime1HOU' THEN 8
					WHEN Bettype = 'Trader1X2' THEN 5
					WHEN Bettype = 'Standby1X2' THEN 5
					WHEN Bettype = 'OtherTime1X2' THEN 5
					WHEN Bettype = 'Trader1H1X2' THEN 15
					WHEN Bettype = 'Standby1H1X2' THEN 15
					WHEN Bettype = 'OtherTime1H1X2' THEN 15
					WHEN Bettype = 'LA1H' THEN - 1001
					WHEN Bettype = 'Standby1HLA' THEN - 1001
					WHEN Bettype = 'OtherTime1HLA' THEN - 1001
					WHEN Bettype = 'ETPK1HLA' THEN - 1001
					WHEN Bettype = 'LA2H' THEN - 1002
					WHEN Bettype = 'Standby2HLA' THEN - 1002
					WHEN Bettype = 'OtherTime2HLA' THEN - 1002
					WHEN Bettype = 'ETPK2HLA' THEN - 1002
					WHEN Bettype = 'FM' THEN - 1003
					WHEN Bettype = 'AIO' THEN - 1004
					END AS BettypeId
				,CASE 
					WHEN Bettype LIKE '%Standby%' THEN 4
					WHEN Bettype LIKE '%OtherTime%' THEN 2
					WHEN Bettype LIKE '%ETPK%' THEN 3
					ELSE 1
					END AS AssignmentType
				,Trader
			FROM (
				SELECT ma.OWPMatchId
					,[TraderHDP]
					,[StandbyHDP]
					,[OtherTimeHDP]
					,[ETPKHDP]
					,[Trader1HHDP]
					,[Standby1HHDP]
					,[OtherTime1HHDP]
					,[TraderOU]
					,[StandbyOU]
					,[OtherTimeOU]
					,[ETPKOU]
					,[Trader1HOU]
					,[Standby1HOU]
					,[OtherTime1HOU]
					,[Trader1X2]
					,[Standby1X2]
					,[OtherTime1X2]
					,[Trader1H1X2]
					,[Standby1H1X2]
					,[OtherTime1H1X2]
					,[LA1H]
					,[Standby1HLA]
					,[OtherTime1HLA]
					,[ETPK1HLA]
					,[LA2H]
					,[Standby2HLA]
					,[OtherTime2HLA]
					,[ETPK2HLA]
					,FM
					,AIO
				FROM #tblMatches AS asm WITH (NOLOCK)
					INNER JOIN #tblMatchIds AS ma WITH (NOLOCK) ON asm.RowNumber = ma.RowNumber
				) p
			UNPIVOT(Trader FOR Bettype IN ([TraderHDP], [StandbyHDP], [OtherTimeHDP], [ETPKHDP], [Trader1HHDP], [Standby1HHDP], [OtherTime1HHDP], [TraderOU], [StandbyOU], [OtherTimeOU], [ETPKOU], [Trader1HOU], [Standby1HOU], [OtherTime1HOU], [Trader1X2], [Standby1X2], [OtherTime1X2], [Trader1H1X2], [Standby1H1X2], [OtherTime1H1X2], [LA1H], [Standby1HLA], [OtherTime1HLA], [ETPK1HLA], [LA2H], [Standby2HLA], [OtherTime2HLA], [ETPK2HLA], FM, AIO)) AS unpvt
			) AS asm1

		UPDATE asm
		SET asm.UserId = us.UserId
		FROM #tblAssignment AS asm WITH (ROWLOCK)
			INNER JOIN dbo.[User] AS us WITH (NOLOCK) ON asm.Username = us.NickName
			OR asm.Username = us.Username

		DELETE
		FROM #tblAssignment
		WHERE UserId IS NULL

		PRINT 'end temp Assignment'
		PRINT DATEDIFF(MILLISECOND, @FromTime, GETDATE())

		-- linked suspender
		INSERT INTO #tblAssignment (
			OWPMatchId
			,BetTypeId
			,AssignmentType
			,UserId
			)
		SELECT mi.MinorMatchId
			,mib.InheritedBettypeId
			,asm.AssignmentType
			,asm.UserId
		FROM dbo.OWPMatch AS m WITH (NOLOCK)
			INNER JOIN dbo.MinorMatch AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.ParentMatchId
			INNER JOIN #tblAssignment AS asm WITH (NOLOCK) ON m.OWPMatchId = asm.OWPMatchId
			INNER JOIN dbo.MinorBettype AS mib WITH (NOLOCK) ON mi.MinorBettypeId = mib.ParentBettypeId
			AND mib.LinkBettypeId = asm.BetTypeId
		WHERE EXISTS (
				SELECT 1
				FROM #tblMatchIds WITH (NOLOCK)
				WHERE OWPMatchId = m.OWPMatchId
				)
			AND EXISTS (
				SELECT 1
				FROM #tblMatchIds WITH (NOLOCK)
				WHERE OWPMatchId = mi.MinorMatchId
				)
			AND NOT EXISTS (
				SELECT 1
				FROM #tblAssignment WITH (NOLOCK)
				WHERE mi.MinorMatchId = OWPMatchId
					AND asm.AssignmentType = AssignmentType
					AND asm.BetTypeId = BetTypeId
				)

		INSERT INTO #tblAssignment (
			OWPMatchId
			,BetTypeId
			,AssignmentType
			,UserId
			)
		SELECT mi1.MinorMatchId
			,mib1.InheritedBettypeId
			,asm.AssignmentType
			,asm.UserId
		FROM dbo.OWPMatch AS m WITH (NOLOCK)
			INNER JOIN #tblAssignment AS asm WITH (NOLOCK) ON m.OWPMatchId = asm.OWPMatchId
			INNER JOIN dbo.MinorMatch AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.MinorMatchId
			INNER JOIN dbo.MinorBettype AS mib WITH (NOLOCK) ON mi.MinorBettypeId = mib.ParentBettypeId
			INNER JOIN dbo.MinorBettype AS mib1 WITH (NOLOCK) ON mib.MinorBettypeId = mib1.LinkBettypeId
			AND mib1.InheritedBettypeId = asm.BetTypeId
			INNER JOIN dbo.MinorMatch AS mi1 WITH (NOLOCK) ON mi1.MinorBettypeId = mib1.ParentBettypeId
			AND mi.ParentMatchId = mi1.ParentMatchId
		WHERE EXISTS (
				SELECT 1
				FROM #tblMatchIds WITH (NOLOCK)
				WHERE OWPMatchId = m.OWPMatchId
				)
			AND EXISTS (
				SELECT 1
				FROM #tblMatchIds WITH (NOLOCK)
				WHERE OWPMatchId = mi1.MinorMatchId
				)
			AND NOT EXISTS (
				SELECT 1
				FROM #tblAssignment WITH (NOLOCK)
				WHERE mi1.MinorMatchId = OWPMatchId
					AND asm.AssignmentType = AssignmentType
					AND asm.BetTypeId = BetTypeId
				)

		-- end linked suspender
		DELETE asm
		OUTPUT deleted.OWPMatchId
			,deleted.Bettype
			,deleted.AssignmentType
			,deleted.UserId
		INTO #tblDeletedAssignment
		FROM dbo.Assignment AS asm WITH (UPDLOCK)
			INNER JOIN (
			SELECT OWPMatchId
			FROM #tblMatchIds WITH (NOLOCK)
			
			UNION
			SELECT OWPMatchId
			FROM #tblRemoveMatchIds WITH (NOLOCK)
			) AS ma ON asm.OWPMatchId = ma.OWPMatchId
		WHERE NOT EXISTS (
				SELECT 1
				FROM #tblAssignment WITH (NOLOCK)
				WHERE OWPMatchId = asm.OWPMatchId
					AND BetTypeId = asm.Bettype
					AND AssignmentType = asm.AssignmentType
				)
			OR EXISTS (
				SELECT 1
				FROM #tblAssignment WITH (NOLOCK)
				WHERE OWPMatchId = asm.OWPMatchId
					AND BetTypeId = asm.Bettype
					AND AssignmentType = asm.AssignmentType
					AND UserId <> asm.UserId
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
			,asg.BetTypeId
			,asg.AssignmentType
			,asg.UserId
			,1
		FROM #tblAssignment AS asg WITH (NOLOCK)
		WHERE NOT EXISTS (
				SELECT 1
				FROM dbo.Assignment WITH (NOLOCK)
				WHERE OWPMatchId = asg.OWPMatchId
					AND BetType = asg.BetTypeId
					AND AssignmentType = asg.AssignmentType
				)

		--notification
		-- renotification when match is not cancelled/postponed/suspended
		INSERT INTO #tblInsertedAssignment (
			OWPMatchId
			,UserId
			,Bettype
			,AssignmentType
			)
		SELECT a.OWPMatchId
			,a.UserId
			,a.BetTypeId
			,a.AssignmentType
		FROM #tblAssignment AS a WITH (NOLOCK)
			INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON a.OWPMatchId = info.OWPMatchId
			AND (info.MatchStatus = @str_Live)
			LEFT JOIN #tblOldMatchInfo AS oldinfo WITH (NOLOCK) ON a.OWPMatchId = oldinfo.OWPMatchId
		WHERE oldinfo.MatchStatus IN (@str_Cancel, @str_Postponed, @str_Suspended)
			AND NOT EXISTS (
				SELECT 1
				FROM #tblInsertedAssignment AS tbl WITH (NOLOCK)
				WHERE a.OWPMatchId = tbl.OWPMatchId
					AND a.UserId = tbl.UserId
					AND a.BetTypeId = tbl.Bettype
					AND a.AssignmentType = tbl.AssignmentType
				)

		PRINT 'end Assignment'
		PRINT DATEDIFF(MILLISECOND, @FromTime, GETDATE())

		-- send message by condition date
		SELECT @FromTimeSendMessage = FromTime
			,@ToTimeSendMessage = ToTime
			,@FromTimeSendMessageSpecialBettype = FromTimeForSpecialBettype
			,@ToTimeSendMessageSpecialBettype = ToTimeForSpecialBettype
		FROM dbo.fnc_GetDateTimeForTraderViewTime()

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

		INSERT INTO #tblMessage (
			UserId
			,MessageContent
			,MessageTypeId
			)
		SELECT u.UserId
			,REPLACE(CASE 
					WHEN asm.MinorBettypeName IS NULL
						AND asm.Bettype = 1 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', 'HDP')
					WHEN asm.MinorBettypeName IS NULL
						AND asm.Bettype = 3 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', 'OU')
					WHEN asm.MinorBettypeName IS NULL
						AND asm.Bettype = 5 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', '1X2')
					WHEN asm.MinorBettypeName IS NULL
						AND asm.Bettype = 7 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', '1H HDP')
					WHEN asm.MinorBettypeName IS NULL
						AND asm.Bettype = 8 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', '1H OU')
					WHEN asm.MinorBettypeName IS NULL
						AND asm.Bettype = 15 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', '1H 1X2')
					WHEN asm.MinorBettypeName IS NULL
						AND asm.Bettype = - 1001 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', '1H LA')
					WHEN asm.MinorBettypeName IS NULL
						AND asm.Bettype = - 1002 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', '2H LA')
					WHEN asm.MinorBettypeName IS NULL
						AND asm.Bettype = - 1003 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', 'FM')
					WHEN asm.MinorBettypeName IS NULL
						AND asm.Bettype = - 1004 THEN REPLACE(@MessageDeleteAssignment, '<bettype>', 'AIO')
					ELSE REPLACE(@MessageDeleteAssignment, '<bettype>', asm.MinorBettypeName)
					END, '<event>', ht.OWPTeamName + ' vs ' + at.OWPTeamName)
			,@MessageDeleteAssignmentId
		FROM (
			SELECT a.UserId
				,CASE 
					WHEN mim.MinorMatchId IS NULL THEN a.OWPMatchId
					ELSE mim.ParentMatchId
					END AS OWPMatchId
				,mibt.MinorBettypeName
				,a.Bettype
				,mim.MinorMatchId
			FROM #tblDeletedAssignment AS a WITH (NOLOCK)
				LEFT JOIN dbo.MinorMatch AS mim WITH (NOLOCK) ON a.OWPMatchId = mim.MinorMatchId
				LEFT JOIN dbo.MinorBettype AS mibt WITH (NOLOCK) ON mim.MinorBettypeId = mibt.ParentBettypeId
				AND a.Bettype = mibt.InheritedBettypeId
			) AS asm
			INNER JOIN dbo.OWPMatch AS ma WITH (NOLOCK) ON asm.OWPMatchId = ma.OWPMatchId
			INNER JOIN dbo.OWPTeam AS ht WITH (NOLOCK) ON ma.OWPHomeId = ht.OWPTeamId
			INNER JOIN dbo.OWPTeam AS at WITH (NOLOCK) ON ma.OWPAwayId = at.OWPTeamId
			INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON asm.UserId = u.UserId
		WHERE (
				EXISTS (
					SELECT 1
					FROM #tblMatchIds AS m WITH (NOLOCK)
						INNER JOIN #tblMatches AS mi WITH (NOLOCK) ON m.RowNumber = mi.RowNumber
					WHERE m.OWPMatchId = asm.OWPMatchId
						AND mi.EventDateTime BETWEEN @FromTimeSendMessage
							AND @ToTimeSendMessage
					)
				)
			OR EXISTS (
				SELECT 1
				FROM #tblMatchIds AS m WITH (NOLOCK)
					INNER JOIN #tblMatches AS mi WITH (NOLOCK) ON m.RowNumber = mi.RowNumber
					LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON minor.MinorMatchId = m.OWPMatchId
				WHERE asm.MinorMatchId = minor.MinorMatchId
					AND (
						(
							ISNULL(minor.MinorBettypeId, 0) NOT IN (@NextCornerId, @NextBookingId)
							AND mi.EventDateTime BETWEEN @FromTimeSendMessage
								AND @ToTimeSendMessage
							)
						OR (
							ISNULL(minor.MinorBettypeId, 0) IN (@NextCornerId, @NextBookingId)
							AND mi.EventDateTime BETWEEN @FromTimeSendMessageSpecialBettype
								AND @ToTimeSendMessageSpecialBettype
							)
						)
				)
		
		UNION
		SELECT u.UserId
			,REPLACE(CASE 
					WHEN asm.MinorBettypeName IS NULL
						AND asm.Bettype = 1 THEN REPLACE(@MessageInsertAssignment, '<bettype>', 'HDP')
					WHEN asm.MinorBettypeName IS NULL
						AND asm.Bettype = 3 THEN REPLACE(@MessageInsertAssignment, '<bettype>', 'OU')
					WHEN asm.MinorBettypeName IS NULL
						AND asm.Bettype = 5 THEN REPLACE(@MessageInsertAssignment, '<bettype>', '1X2')
					WHEN asm.MinorBettypeName IS NULL
						AND asm.Bettype = 7 THEN REPLACE(@MessageInsertAssignment, '<bettype>', '1H HDP')
					WHEN asm.MinorBettypeName IS NULL
						AND asm.Bettype = 8 THEN REPLACE(@MessageInsertAssignment, '<bettype>', '1H OU')
					WHEN asm.MinorBettypeName IS NULL
						AND asm.Bettype = 15 THEN REPLACE(@MessageInsertAssignment, '<bettype>', '1H 1X2')
					WHEN asm.MinorBettypeName IS NULL
						AND asm.Bettype = - 1001 THEN REPLACE(@MessageInsertAssignment, '<bettype>', '1H LA')
					WHEN asm.MinorBettypeName IS NULL
						AND asm.Bettype = - 1002 THEN REPLACE(@MessageInsertAssignment, '<bettype>', '2H LA')
					WHEN asm.MinorBettypeName IS NULL
						AND asm.Bettype = - 1003 THEN REPLACE(@MessageInsertAssignment, '<bettype>', 'FM')
					WHEN asm.MinorBettypeName IS NULL
						AND asm.Bettype = - 1004 THEN REPLACE(@MessageInsertAssignment, '<bettype>', 'AIO')
					ELSE REPLACE(@MessageInsertAssignment, '<bettype>', asm.MinorBettypeName)
					END, '<event>', ht.OWPTeamName + ' vs ' + at.OWPTeamName)
			,@MessageInsertAssignmentId
		FROM (
			SELECT a.UserId
				,CASE 
					WHEN mim.MinorMatchId IS NULL THEN a.OWPMatchId
					ELSE mim.ParentMatchId
					END AS OWPMatchId
				,mibt.MinorBettypeName
				,a.Bettype
				,mim.MinorMatchId
			FROM #tblInsertedAssignment AS a WITH (NOLOCK)
				INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON a.OWPMatchId = info.OWPMatchId --Send message to all match status
				--AND info.MatchStatus = @str_Live
				--AND info.IsCancelled = 0 (Note: Only send message assign to Match is live)
				LEFT JOIN dbo.MinorMatch AS mim WITH (NOLOCK) ON a.OWPMatchId = mim.MinorMatchId
				LEFT JOIN dbo.MinorBettype AS mibt WITH (NOLOCK) ON mim.MinorBettypeId = mibt.ParentBettypeId
				AND a.Bettype = mibt.InheritedBettypeId
			) AS asm
			INNER JOIN dbo.OWPMatch AS ma WITH (NOLOCK) ON asm.OWPMatchId = ma.OWPMatchId
			INNER JOIN dbo.OWPTeam AS ht WITH (NOLOCK) ON ma.OWPHomeId = ht.OWPTeamId
			INNER JOIN dbo.OWPTeam AS at WITH (NOLOCK) ON ma.OWPAwayId = at.OWPTeamId
			INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON asm.UserId = u.UserId
		WHERE (
				asm.MinorMatchId IS NULL
				AND EXISTS (
					SELECT 1
					FROM #tblMatchIds AS m WITH (NOLOCK)
						INNER JOIN #tblMatches AS mi WITH (NOLOCK) ON m.RowNumber = mi.RowNumber
					WHERE m.OWPMatchId = asm.OWPMatchId
						AND mi.EventDateTime BETWEEN @FromTimeSendMessage
							AND @ToTimeSendMessage
					)
				)
			OR EXISTS (
				SELECT 1
				FROM dbo.MinorMatch AS minor WITH (NOLOCK)
					INNER JOIN #tblMatchIds AS m WITH (NOLOCK) ON minor.MinorMatchId = m.OWPMatchId
					INNER JOIN #tblMatches AS mi WITH (NOLOCK) ON m.RowNumber = mi.RowNumber
				WHERE asm.MinorMatchId = minor.MinorMatchId
					AND (
						(
							minor.MinorBettypeId NOT IN (@NextCornerId, @NextBookingId)
							AND mi.EventDateTime BETWEEN @FromTimeSendMessage
								AND @ToTimeSendMessage
							)
						OR (
							minor.MinorBettypeId IN (@NextCornerId, @NextBookingId)
							AND mi.EventDateTime BETWEEN @FromTimeSendMessageSpecialBettype
								AND @ToTimeSendMessageSpecialBettype
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
		INTO dbo.MessageUser([MessageId], [UserId], [CreatedDate], [CreatedBy], [SessionId]);

		-- message for match cancelled
		TRUNCATE TABLE #tblMessage

		-- parent match cancelled
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
					WHEN minor.MinorMatchId IS NULL THEN a.OWPMatchId
					ELSE minor.ParentMatchId END
					) AS OWPMatchId
			FROM dbo.Assignment AS a WITH (NOLOCK)
				INNER JOIN #tblMatchIds AS mid WITH (NOLOCK) ON a.OWPMatchId = mid.OWPMatchId
				AND mid.IsUpdated = 1
				LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON a.OWPMatchId = minor.MinorMatchId
			) AS asm
			INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON asm.OWPMatchId = om.OWPMatchId
			INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON om.OWPMatchId = info.OWPMatchId
			--AND info.IsCancelled = 1
			INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
			INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
			LEFT JOIN #tblOldMatchInfo AS oldinfo WITH (NOLOCK) ON om.OWPMatchId = oldinfo.OWPMatchId
		WHERE om.EventDateTime BETWEEN @FromTimeSendMessage
				AND @ToTimeSendMessage
			AND ( 
				oldinfo.MatchStatus IN ('', @str_Live) AND info.MatchStatus IN (@str_Cancel, @str_Postponed, @str_Suspended)
				OR oldinfo.MatchStatus = (@str_Cancel) AND info.MatchStatus IN (@str_Postponed, @str_Suspended)
				OR oldinfo.MatchStatus = (@str_Postponed) AND info.MatchStatus IN (@str_Cancel, @str_Suspended)
				OR oldinfo.MatchStatus = (@str_Suspended) AND info.MatchStatus IN (@str_Cancel, @str_Postponed)
				)
		
		UNION
		-- minor match cancelled
		SELECT asm.UserId
			,REPLACE(REPLACE(@MessageMatchStatus, '<event>', (CASE 
					WHEN LEN(ISNULL(om.MatchNo, '')) = 0 THEN ''
					ELSE om.MatchNo + ' - ' END
					) + home.OWPTeamName + ' vs ' + away.OWPTeamName), '<status>', info.MatchStatus)
			,@MessageMatchStatusId
		FROM (
			SELECT DISTINCT a.UserId
				,a.OWPMatchId
				,minor.MinorBettypeId
			FROM dbo.Assignment AS a WITH (NOLOCK)
				INNER JOIN #tblMatchIds AS mid WITH (NOLOCK) ON a.OWPMatchId = mid.OWPMatchId
				AND mid.IsUpdated = 1
				INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON a.OWPMatchId = minor.MinorMatchId
					AND minor.MinorBettypeId NOT IN (-1, -2, -5, -8)
				INNER JOIN dbo.MatchInfo AS pinfo WITH (NOLOCK) ON minor.ParentMatchId = pinfo.OWPMatchId
				LEFT JOIN dbo.MinorMatch AS m15mins WITH (NOLOCK) ON minor.ParentMatchId = m15mins.ParentMatchId
				AND (
					(
						minor.MinorBettypeId = @NoOfCorners
						AND m15mins.MinorBettypeId = @Specific15MinsNoOfCorners
						)
					OR (
						minor.MinorBettypeId = @TotalBooking
						AND m15mins.MinorBettypeId = @Specific15MinsTotalBooking
						)
					)
			) AS asm
			INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON asm.OWPMatchId = om.OWPMatchId
			INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON om.OWPMatchId = info.OWPMatchId
			--AND info.IsCancelled = 1
			INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
			INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
			LEFT JOIN #tblOldMatchInfo AS oldinfo WITH (NOLOCK) ON om.OWPMatchId = oldinfo.OWPMatchId
		WHERE (
				om.EventDateTime BETWEEN @FromTimeSendMessage
					AND @ToTimeSendMessage
				OR (
					asm.MinorBettypeId IN (@NextCornerId, @NextBookingId)
					AND om.EventDateTime BETWEEN @FromTimeSendMessageSpecialBettype
						AND @ToTimeSendMessageSpecialBettype
					)
				)
			AND ( 
				oldinfo.MatchStatus IN ('', @str_Live) AND info.MatchStatus IN (@str_Cancel, @str_Postponed, @str_Suspended)
				OR oldinfo.MatchStatus = (@str_Cancel) AND info.MatchStatus IN (@str_Postponed, @str_Suspended)
				OR oldinfo.MatchStatus = (@str_Postponed) AND info.MatchStatus IN (@str_Cancel, @str_Suspended)
				OR oldinfo.MatchStatus = (@str_Suspended) AND info.MatchStatus IN (@str_Cancel, @str_Postponed)
				)

--------------
		INSERT INTO dbo.[Message] (
			MessageContent
			,CreatedBy
			,CreatedDate
			,IsImportant
			,IsPermanent
			,MessageType
			)
		OUTPUT inserted.MessageId
			,inserted.MessageContent
			,inserted.MessageType
		INTO #tblMessageMatchCancelled(MessageId, MessageContent, MessageTypeId)
		SELECT DISTINCT MessageContent
			,@UserId
			,GETDATE()
			,1
			,0
			,MessageTypeId
		FROM #tblMessage WITH (NOLOCK)

		INSERT INTO dbo.MessageUser (
			[MessageId]
			,[UserId]
			,[CreatedDate]
			,[CreatedBy]
			,[SessionId]
			)
		SELECT DISTINCT msn.MessageId
			,ms.UserId
			,GETDATE()
			,@UserId
			,@SessionId
		FROM #tblMessage AS ms WITH (NOLOCK)
			INNER JOIN #tblMessageMatchCancelled AS msn WITH (NOLOCK) ON ms.MessageContent = msn.MessageContent
			AND msn.MessageTypeId = ms.MessageTypeId
			LEFT JOIN dbo.MessageUser AS msu WITH (NOLOCK) ON msn.MessageId = msu.MessageId
			AND ms.UserId = msu.UserId
		WHERE msu.MessageId IS NULL

		PRINT 'end message'
		PRINT DATEDIFF(MILLISECOND, @FromTime, GETDATE())

		-- Log Assignment
		INSERT INTO #tblLogs (
			CreatorId
			,LoggedDate
			,ObjectId
			,ActionId
			,Duration
			,Data
			,DataOld
			)
		SELECT @UserId
			,GETDATE()
			,OWPMatchId
			,53
			,@Duration
			,'<r><z mt="' + asmt.OWPMatchId + '" bt="' + asmt.Bettype + '" at="' + asmt.AssignmentType + '" il="1" us="' + asmt.NewUserId + '"/></r>'
			,'<r><z mt="' + asmt.OWPMatchId + '" bt="' + asmt.Bettype + '" at="' + asmt.AssignmentType + '" il="1" us="' + asmt.OldUserId + '"/></r>'
		FROM (
			SELECT CAST(CASE 
						WHEN oas.OWPMatchId IS NULL THEN asm.OWPMatchId
						ELSE oas.OWPMatchId
						END AS VARCHAR(10)) AS OWPMatchId
				,CAST(CASE 
						WHEN oas.OWPMatchId IS NULL THEN asm.Bettype
						ELSE oas.BetTypeId
						END AS VARCHAR(10)) AS Bettype
				,CAST(CASE 
						WHEN oas.OWPMatchId IS NULL THEN asm.AssignmentType
						ELSE oas.AssignmentType
						END AS VARCHAR(10)) AS AssignmentType
				,CAST(oas.UserId AS VARCHAR(15)) AS OldUserId
				,CAST(asm.UserId AS VARCHAR(15)) AS NewUserId
			FROM (
				#tblOldAssignment AS oas
					FULL OUTER JOIN (
					SELECT ass.OWPMatchId
						,ass.Bettype
						,ass.AssignmentType
						,ass.UserId
					FROM #tblMatchIds AS ma WITH (NOLOCK)
						INNER JOIN dbo.Assignment AS ass WITH (NOLOCK) ON ma.OWPMatchId = ass.OWPMatchId
					) AS asm ON oas.OWPMatchId = asm.OWPMatchId
					AND oas.BetTypeId = asm.Bettype
					AND oas.AssignmentType = asm.AssignmentType
				)
			WHERE ISNULL(oas.UserId, 0) <> ISNULL(asm.UserId, 0)
			) AS asmt

		INSERT INTO UserLog (
			CreatorId
			,LoggedDate
			,ActionId
			,ObjectId
			,Duration
			,Data
			,DataOld
			)
		SELECT CreatorId
			,LoggedDate
			,ActionId
			,ObjectId
			,Duration
			,Data
			,DataOld
		FROM #tblLogs

		-- Remove minor match not exists in file
		DELETE mat
		FROM dbo.OWPMatch AS mat WITH (UPDLOCK)
			INNER JOIN dbo.MinorMatch AS mi WITH (NOLOCK) ON mat.OWPMatchId = mi.MinorMatchId
		WHERE EXISTS (
				SELECT 1
				FROM #tblRemoveMatchIds WITH (NOLOCK)
				WHERE OWPMatchId = mi.MinorMatchId
				)

		DELETE mat
		FROM dbo.MatchInfo AS mat WITH (UPDLOCK)
			INNER JOIN dbo.MinorMatch AS mi WITH (NOLOCK) ON mat.OWPMatchId = mi.MinorMatchId
		WHERE EXISTS (
				SELECT 1
				FROM #tblRemoveMatchIds WITH (NOLOCK)
				WHERE OWPMatchId = mi.MinorMatchId
				)

		DELETE mat
		FROM dbo.Assignment AS mat WITH (UPDLOCK)
			INNER JOIN dbo.MinorMatch AS mi WITH (NOLOCK) ON mat.OWPMatchId = mi.MinorMatchId
		WHERE EXISTS (
				SELECT 1
				FROM #tblRemoveMatchIds WITH (NOLOCK)
				WHERE OWPMatchId = mi.MinorMatchId
				)

		DELETE mat
		FROM dbo.MatchSetting AS mat WITH (UPDLOCK)
			INNER JOIN dbo.MinorMatch AS mi WITH (NOLOCK) ON mat.OWPMatchId = mi.MinorMatchId
		WHERE EXISTS (
				SELECT 1
				FROM #tblRemoveMatchIds WITH (NOLOCK)
				WHERE OWPMatchId = mi.MinorMatchId
				)

		DELETE mi
		FROM dbo.MinorMatch mi WITH (UPDLOCK)
		WHERE EXISTS (
				SELECT 1
				FROM #tblRemoveMatchIds WITH (NOLOCK)
				WHERE OWPMatchId = mi.MinorMatchId
				)

		UPDATE mif
		SET mif.IsSelected = 0
			,mif.IsSelectedUpdatedDate = GETDATE()
		FROM #tblMatchIds AS mat WITH (NOLOCK)
			INNER JOIN dbo.MatchInfo AS mif WITH (ROWLOCK) ON mif.OWPMatchId = mat.OWPMatchId
		WHERE EXISTS (
				SELECT 1
				FROM dbo.MinorMatch AS mi WITH (NOLOCK)
					INNER JOIN dbo.MatchInfo AS m WITH (NOLOCK) ON mi.ParentMatchId = m.OWPMatchId
					AND m.IsSelected = 0
				WHERE mat.OWPMatchId = mi.MinorMatchId
				)

		-- End remove minor match not exists in file
		EXEC dbo.OWP_Trade5MatchPerDay_RunAfterInsertAssignment @OWPEventDate = @EventDate

		PRINT 'end log assignment'
		PRINT DATEDIFF(MILLISECOND, @FromTime, GETDATE())
	END TRY

	BEGIN CATCH
		BEGIN
			SELECT @ErrCode = 1
				,@ErrMsg = 'Uploading Fail.'
		END
	END CATCH

	UPDATE dbo.AssignmentUploadingLog WITH (ROWLOCK, UPDLOCK)
	SET [Status] = 5 -- success
		,EndDate = GETDATE()
	WHERE SessionId = @SessionId
		AND [Status] = 4 -- submit

	DROP TABLE #tblMatches

	DROP TABLE #tblMatchIds

	DROP TABLE #tblRemoveMatchIds

	DROP TABLE #tblOldMatchNote

	DROP TABLE #tblMatchNote

	DROP TABLE #tblOldMatchInfo

	DROP TABLE #tblRefResource

	DROP TABLE #tblNewRefResourceIds

	DROP TABLE #tblOldRefResourceValues

	DROP TABLE #tblMatchSetting

	DROP TABLE #tblOldMatchSetting

	DROP TABLE #tblAssignment

	DROP TABLE #tblOldAssignment

	DROP TABLE #tblDeletedAssignment

	DROP TABLE #tblInsertedAssignment

	DROP TABLE #tblMessage

	DROP TABLE #tblLogs

	DROP TABLE #tblMessageMatchCancelled
END