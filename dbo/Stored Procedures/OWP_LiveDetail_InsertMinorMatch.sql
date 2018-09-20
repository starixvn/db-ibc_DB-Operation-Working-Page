CREATE PROCEDURE [dbo].[OWP_LiveDetail_InsertMinorMatch] @UserId INT
	,@OWPMatchId INT
	,@MinorBettypeIds NVARCHAR(MAX)
	,@SessionId NVARCHAR(100) = ''
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20170317@Tim.Trinh
Task : Insert minor match
DB: bodb_OWP

Revisions:
   
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @League NVARCHAR(2000)
		,@Home NVARCHAR(200)
		,@Away NVARCHAR(200)
		,@EventDate DATE
		,@KickOffTime TIME
		,@EventDateTime DATETIME
		,@IsSelected BIT = 0
		,@MatchStatus NVARCHAR(15) = ''

	DECLARE @StartRun DATETIME = GETDATE()
		,@MessageInsertAssignment NVARCHAR(MAX)
		,@MessageInsertAssignmentId INT
		,@FromTimeSendMessage DATETIME
		,@ToTimeSendMessage DATETIME
		,@FromTimeSendMessageSpecialBettype DATETIME
		,@ToTimeSendMessageSpecialBettype DATETIME
		,@NextCornerId INT = - 4
		,@NextBookingId INT = - 7

		-- Match Status
		,@str_Live NVARCHAR(15) = 'Live'
		,@str_Cancel NVARCHAR(15) = 'Cancel'
		,@str_Postponed NVARCHAR(15) = 'Postponed'
		,@str_Suspended NVARCHAR(15) = 'Suspended'

	CREATE TABLE #tblMinorBettypeId (MinorBettypeId INT)

	CREATE TABLE #tblMinorMatch (
		OWPMatchId INT
		,MinorBettypeId INT
		,OWPLeagueId INT
		,League NVARCHAR(2000)
		,HomeId INT
		,Home NVARCHAR(200)
		,AwayId INT
		,Away NVARCHAR(200)
		,IsRepresented BIT
		,Inserted BIT
		)

	CREATE TABLE #tblUserLogs (
		CreatorId INT
		,LoggedDate DATETIME
		,Duration INT
		,ObjectId INT
		,ActionId INT
		,Data NVARCHAR(MAX)
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

	SELECT @League = league.OWPLeagueName
		,@Home = home.OWPTeamName
		,@Away = away.OWPTeamName
		,@EventDate = om.EventDate
		,@KickOffTime = om.KickOffTime
		,@EventDateTime = om.EventDateTime
		,@IsSelected = info.IsSelected
		,@MatchStatus = info.MatchStatus
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
		INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON om.OWPLeagueId = league.OWPLeagueId
		INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
		INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
		INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON om.OWPMatchId = info.OWPMatchId
	WHERE om.OWPMatchId = @OWPMatchId

	IF @MinorBettypeIds IS NOT NULL
	BEGIN
		INSERT INTO #tblMinorBettypeId (MinorBettypeId)
		SELECT [val]
		FROM dbo.fnc_SplitStrings(@MinorBettypeIds, ',')
	END

	INSERT INTO #tblMinorMatch (
		MinorBettypeId
		,League
		,Home
		,Away
		,IsRepresented
		,Inserted
		)
	SELECT t.MinorBettypeId
		,REPLACE(t.League, '<name>', @League)
		,REPLACE(t.Home, '<name>', @Home)
		,REPLACE(t.Away, '<name>', @Away)
		,t.IsRepresented
		,0
	FROM dbo.MinorMatchTemplateSetting AS t WITH (NOLOCK)
		INNER JOIN #tblMinorBettypeId AS mid WITH (NOLOCK) ON t.MinorBettypeId = mid.MinorBettypeId

	UPDATE minor
	SET minor.OWPMatchId = om.OWPMatchId
		,minor.OWPLeagueId = om.OWPLeagueId
		,minor.HomeId = om.OWPHomeId
		,minor.AwayId = om.OWPAwayId
		,minor.Inserted = 1
	FROM #tblMinorMatch AS minor
		INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON league.OWPLeagueName = minor.League
		INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON home.OWPTeamName = minor.Home
		INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON away.OWPTeamName = minor.Away
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON om.EventDate = @EventDate
		AND om.KickOffTime = @KickOffTime
		AND om.OWPLeagueId = league.OWPLeagueId
		AND om.OWPHomeId = home.OWPTeamId
		AND om.OWPAwayId = away.OWPTeamId

	INSERT INTO dbo.OWPLeague (
		OWPLeagueName
		,IsActive
		)
	OUTPUT @UserId
		,GETDATE()
		,inserted.OWPLeagueId
		,4
		,DATEDIFF(MILLISECOND, @StartRun, GETDATE())
		,'<r><z ln="' + inserted.OWPLeagueName + '"/></r>'
	INTO #tblUserLogs(CreatorId, LoggedDate, ObjectId, ActionId, Duration, Data)
	SELECT DISTINCT League
		,1
	FROM #tblMinorMatch AS minor WITH (NOLOCK)
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.OWPLeague WITH (NOLOCK)
			WHERE OWPLeagueName = minor.League
			)
		AND minor.Inserted = 0

	UPDATE minor
	SET minor.OWPLeagueId = league.OWPLeagueId
	FROM #tblMinorMatch AS minor
		INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON minor.League = league.OWPLeagueName
		AND minor.Inserted = 0

	---- insert home, away
	INSERT INTO dbo.OWPTeam (OWPTeamName)
	OUTPUT @UserId
		,GETDATE()
		,inserted.OWPTeamId
		,7
		,DATEDIFF(MILLISECOND, @StartRun, GETDATE())
		,'<r><z tn="' + inserted.OWPTeamName + '"/></r>'
	INTO #tblUserLogs(CreatorId, LoggedDate, ObjectId, ActionId, Duration, Data)
	SELECT DISTINCT Home
	FROM #tblMinorMatch AS minor WITH (NOLOCK)
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.OWPTeam WITH (NOLOCK)
			WHERE OWPTeamName = minor.Home
			)
		AND minor.Inserted = 0
	
	UNION
	SELECT DISTINCT Away
	FROM #tblMinorMatch AS minor WITH (NOLOCK)
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.OWPTeam WITH (NOLOCK)
			WHERE OWPTeamName = minor.Away
			)
		AND minor.Inserted = 0

	UPDATE minor
	SET minor.HomeId = home.OWPTeamId
	FROM #tblMinorMatch AS minor
		INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON minor.Home = home.OWPTeamName
	WHERE minor.Inserted = 0

	UPDATE minor
	SET minor.AwayId = away.OWPTeamId
	FROM #tblMinorMatch AS minor
		INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON minor.Away = away.OWPTeamName
	WHERE minor.Inserted = 0

	---- insert match
	INSERT INTO dbo.OWPMatch (
		EventDate
		,KickOffTime
		,EventDateTime
		,OWPLeagueId
		,OWPHomeId
		,OWPAwayId
		)
	OUTPUT inserted.OWPMatchId
		,@IsSelected
		,@MatchStatus
		,0
	INTO dbo.MatchInfo(OWPMatchId, IsSelected, MatchStatus, IsSoloMatch)
	SELECT @EventDate
		,@KickOffTime
		,@EventDateTime
		,OWPLeagueId
		,HomeId
		,AwayId
	FROM #tblMinorMatch WITH (NOLOCK)
	WHERE Inserted = 0

	UPDATE minor
	SET minor.OWPMatchId = om.OWPMatchId
	FROM #tblMinorMatch AS minor
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON om.EventDate = @EventDate
		AND om.KickOffTime = @KickOffTime
		AND om.OWPLeagueId = minor.OWPLeagueId
		AND om.OWPHomeId = minor.HomeId
		AND om.OWPAwayId = minor.AwayId
	WHERE minor.Inserted = 0

	-- insert minor match
	INSERT INTO dbo.MinorMatch (
		MinorMatchId
		,ParentMatchId
		,MinorBettypeId
		,IsRepresented
		)
	SELECT OWPMatchId
		,@OWPMatchId
		,MinorBettypeId
		,IsRepresented
	FROM #tblMinorMatch AS minor WITH (NOLOCK)
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.MinorMatch WITH (NOLOCK)
			WHERE MinorMatchId = minor.OWPMatchId
				AND ParentMatchId = @OWPMatchId
				AND MinorBettypeId = minor.MinorBettypeId
			)

	INSERT INTO dbo.Assignment (
		OWPMatchId
		,BetType
		,AssignmentType
		,UserId
		,IsLive
		)
	OUTPUT inserted.OWPMatchId
		,inserted.Bettype
		,inserted.AssignmentType
		,inserted.UserId
	INTO #tblInsertedAssignment
	SELECT mi.MinorMatchId
		,mib.InheritedBettypeId
		,asm.AssignmentType
		,asm.UserId
		,1
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
		INNER JOIN dbo.MinorMatch AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.ParentMatchId
		INNER JOIN dbo.Assignment AS asm WITH (NOLOCK) ON m.OWPMatchId = asm.OWPMatchId
		INNER JOIN dbo.MinorBettype AS mib WITH (NOLOCK) ON mi.MinorBettypeId = mib.ParentBettypeId
		AND mib.LinkBettypeId = asm.Bettype
		INNER JOIN #tblMinorMatch AS mm WITH (NOLOCK) ON mi.MinorMatchId = mm.OWPMatchId
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.Assignment WITH (NOLOCK)
			WHERE mi.MinorMatchId = OWPMatchId
				AND asm.AssignmentType = AssignmentType
				AND asm.BetType = BetType
			)
	
	UNION
	SELECT mi1.MinorMatchId
		,mib1.InheritedBettypeId
		,asm.AssignmentType
		,asm.UserId
		,1
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
		INNER JOIN dbo.Assignment AS asm WITH (NOLOCK) ON m.OWPMatchId = asm.OWPMatchId
		INNER JOIN dbo.MinorMatch AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.MinorMatchId
		INNER JOIN dbo.MinorBettype AS mib WITH (NOLOCK) ON mi.MinorBettypeId = mib.ParentBettypeId
		INNER JOIN dbo.MinorBettype AS mib1 WITH (NOLOCK) ON mib.MinorBettypeId = mib1.LinkBettypeId
		AND mib1.InheritedBettypeId = asm.Bettype
		INNER JOIN dbo.MinorMatch AS mi1 WITH (NOLOCK) ON mi1.MinorBettypeId = mib1.ParentBettypeId
		AND mi.ParentMatchId = mi1.ParentMatchId
		INNER JOIN #tblMinorMatch AS mm WITH (NOLOCK) ON mi1.MinorMatchId = mm.OWPMatchId
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.Assignment WITH (NOLOCK)
			WHERE mi1.MinorMatchId = OWPMatchId
				AND asm.AssignmentType = AssignmentType
				AND asm.BetType = BetType
			)

	-- send message by condition date
	SELECT @FromTimeSendMessage = FromTime
		,@ToTimeSendMessage = ToTime
		,@FromTimeSendMessageSpecialBettype = FromTimeForSpecialBettype
		,@ToTimeSendMessageSpecialBettype = ToTimeForSpecialBettype
	FROM dbo.fnc_GetDateTimeForTraderViewTime()

	SELECT @MessageInsertAssignment = mt.MsgTemplateContent
		,@MessageInsertAssignmentId = mt.MsgTemplateId
	FROM dbo.MessageTemplate mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'AssignmentInsert'

	INSERT INTO #tblMessage (
		UserId
		,MessageContent
		,MessageTypeId
		)
	SELECT a.UserId
		,REPLACE(REPLACE(@MessageInsertAssignment, '<bettype>', mibt.MinorBettypeName), '<event>', @Home + ' vs ' + @Away)
		,@MessageInsertAssignmentId
	FROM dbo.MinorMatch AS minor WITH (NOLOCK)
		INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON minor.MinorMatchId = info.OWPMatchId
			AND info.MatchStatus = @str_Live
		--AND info.IsCancelled = 0 (Note: Only send message assign to Match is live)
		INNER JOIN #tblInsertedAssignment AS a WITH (NOLOCK) ON info.OWPMatchId = a.OWPMatchId
		INNER JOIN dbo.MinorBettype AS mibt WITH (NOLOCK) ON minor.MinorBettypeId = mibt.ParentBettypeId
		AND a.Bettype = mibt.InheritedBettypeId
	WHERE minor.ParentMatchId = @OWPMatchId
		AND (
			(
				minor.MinorBettypeId NOT IN (@NextCornerId, @NextBookingId)
				AND @EventDateTime BETWEEN @FromTimeSendMessage
					AND @ToTimeSendMessage
				)
			OR (
				minor.MinorBettypeId IN (@NextCornerId, @NextBookingId)
				AND @EventDateTime BETWEEN @FromTimeSendMessageSpecialBettype
					AND @ToTimeSendMessageSpecialBettype
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

	---- Log Assignment
	INSERT INTO #tblUserLogs (
		CreatorId
		,LoggedDate
		,ObjectId
		,ActionId
		,Duration
		,Data
		)
	SELECT @UserId
		,GETDATE()
		,OWPMatchId
		,53
		,0
		,'<r><z mt="' + CAST(asmt.OWPMatchId AS VARCHAR(20)) + '" bt="' + CAST(asmt.Bettype AS VARCHAR(20)) + '" at="' + CAST(asmt.AssignmentType AS VARCHAR(20)) + '" il="1" us="' + CAST(ISNULL(asmt.UserId, '') AS VARCHAR(20)) + '"/></r>'
	FROM #tblInsertedAssignment AS asmt WITH (NOLOCK)

	-- write log
	INSERT INTO dbo.UserLog (
		CreatorId
		,LoggedDate
		,ObjectId
		,ActionId
		,Duration
		,Data
		)
	SELECT CreatorId
		,LoggedDate
		,ObjectId
		,ActionId
		,Duration
		,Data
	FROM #tblUserLogs WITH (NOLOCK)

	DROP TABLE #tblMinorBettypeId

	DROP TABLE #tblUserLogs

	DROP TABLE #tblMinorMatch
END