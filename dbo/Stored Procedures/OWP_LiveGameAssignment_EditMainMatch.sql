
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_EditMainMatch] @OWPMatchId INT
	,@LeagueName NVARCHAR(500)
	,@HomeName NVARCHAR(200)
	,@AwayName NVARCHAR(200)
	,@MatchNo VARCHAR(50) = ''
	,@KickOffTime TIME(7)
	,@ActorId INT = NULL
	,@SessionId VARCHAR(50) = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(MAX) = '' OUTPUT
AS
/*
 Created: 20190725@Kane.Le
 Task : add new event
 DB: bodb_OWP

 Revisions:
	20190724@Kane.Le: Initial SP - [Feature: #117461]
	20191021@Leo.Vo: Check duplicate match - [Redmine: #120415]
*/
BEGIN
	SET NOCOUNT ON

	EXEC dbo.OWP_LiveGameAssignment_EditSingleMatch @OWPMatchId = @OWPMatchId
		,@LeagueName = @LeagueName
		,@HomeName = @HomeName
		,@AwayName = @AwayName
		,@MatchNo = @MatchNo
		,@ActorId = @ActorId
		,@SessionId = @SessionId
		,@KickOffTime = @KickOffTime
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT

	DECLARE @FromDateTime DATETIME
		,@ToDateTime DATETIME
		
	SELECT @FromDateTime = FromDateTime
		,@ToDateTime = ToDateTime
	FROM [fnc_GetFromDateToDateOfMatch](@OWPMatchId)
			
	CREATE TABLE #tblOWPMatchByEventDate (
		RowNumber INT IDENTITY PRIMARY KEY CLUSTERED
		,OWPMatchId INT
		,LeagueName NVARCHAR(500)
		,HomeName NVARCHAR(200)
		,AwayName NVARCHAR(200)
		,MatchNo NVARCHAR(50)
		,MinorBettypeId INT
		,ParentMatchId INT
		);

	INSERT INTO #tblOWPMatchByEventDate (
		OWPMatchId
		,LeagueName
		,HomeName
		,AwayName
		,MatchNo
		,MinorBettypeId
		,ParentMatchId
		)
	SELECT m.OWPMatchId
		,l.OWPLeagueName
		,h.OWPTeamName
		,a.OWPTeamName
		,m.MatchNo
		,0
		,0
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
	INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
	INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
	INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId
	--INNER JOIN dbo.MinorMatch AS mn WITH (NOLOCK) ON mn.ParentMatchId = m.OWPMatchId
	WHERE m.OWPMatchId <> @OWPMatchId
		AND m.EventDateTime BETWEEN @FromDateTime
			AND @ToDateTime;

	CREATE TABLE #tblSpecialEventTemplate (
		RowNumber INT IDENTITY PRIMARY KEY CLUSTERED
		,LeagueName NVARCHAR(500)
		,HomeName NVARCHAR(200)
		,AwayName NVARCHAR(200)
		,ParentMatchId INT
		,MinorBettypeId INT
		,MinorMatchId INT
		,MatchNo NVARCHAR(50)
		)
	CREATE TABLE #tblSpecialEventTemplateMain (
		RowNumber INT IDENTITY PRIMARY KEY CLUSTERED
		,LeagueName NVARCHAR(500)
		,HomeName NVARCHAR(200)
		,AwayName NVARCHAR(200)
		,ParentMatchId INT
		,MinorBettypeId INT
		,MinorMatchId INT
		,MatchNo NVARCHAR(50)
		)
	DECLARE @tblSpecialEventTemplateMain2Minor TABLE (
		RowNumber INT IDENTITY PRIMARY KEY CLUSTERED
		,LeagueName NVARCHAR(500)
		,HomeName NVARCHAR(200)
		,AwayName NVARCHAR(200)
		,ParentMatchId INT
		,MinorBettypeId INT
		,MinorMatchId INT
		,MatchNo NVARCHAR(50)
		)
	DECLARE @tblMinorBettypeId TABLE (
		RowNumber INT IDENTITY PRIMARY KEY CLUSTERED
		,MinorMatchId INT
		,MinorBettypeId INT
		,ParentMatchId INT
		)

	INSERT INTO @tblMinorBettypeId
	SELECT mm.MinorMatchId
		,mm.MinorBettypeId
		,mm.ParentMatchId
	FROM dbo.MinorMatch AS mm WITH (NOLOCK)
	WHERE ParentMatchId = @OWPMatchId

	DECLARE @LoopCounter INT = 1
		,@MaxRowCount INT
		,@MinorBettypeId INT
		,@ParentMatchId INT
		,@MinorMatchId INT
		,@RowNumber INT

	SET @LoopCounter = 1;

	SELECT @MaxRowCount = COUNT(RowNumber)
	FROM @tblMinorBettypeId

	WHILE (@LoopCounter <= @MaxRowCount)
	BEGIN
		SELECT @MinorBettypeId = MinorBettypeId
			,@ParentMatchId = ParentMatchId
			,@MinorMatchId = MinorMatchId
		FROM @tblMinorBettypeId
		WHERE @LoopCounter = RowNumber

		INSERT INTO #tblSpecialEventTemplate (
			LeagueName
			,HomeName
			,AwayName
			)
		EXEC [dbo].[OWP_LiveGameAssignment_GetSpecialEventTemplate] @ParentMatchId = @OWPMatchId
			,@MinorBettypeId = @MinorBettypeId

		UPDATE #tblSpecialEventTemplate
		SET ParentMatchId = @ParentMatchId
			,MinorBettypeId = @MinorBettypeId
			,MinorMatchId = @MinorMatchId
			,MatchNo = (
				SELECT TOP 1 o.MatchNo
				FROM dbo.OWPMatch AS o WITH (NOLOCK)
				WHERE o.OWPMatchId = @MinorMatchId
				)
		WHERE @LoopCounter = RowNumber

		SET @LoopCounter = @LoopCounter + 1
	END

	INSERT INTO #tblSpecialEventTemplateMain (
		LeagueName
		,HomeName
		,AwayName
		)
	EXEC [dbo].[OWP_LiveGameAssignment_GetSpecialEventTemplate] @ParentMatchId = @OWPMatchId

	INSERT INTO @tblSpecialEventTemplateMain2Minor (
		LeagueName
		,HomeName
		,AwayName
		,MinorMatchId
		,ParentMatchId
		)
	SELECT m.LeagueName
		,m.HomeName
		,m.AwayName
		,m.OWPMatchId
		,@OWPMatchId
	FROM #tblOWPMatchByEventDate AS m
	JOIN #tblSpecialEventTemplateMain AS t ON m.LeagueName = t.LeagueName
		AND m.HomeName = t.HomeName
		AND m.AwayName = t.AwayName
	WHERE NOT EXISTS (
			SELECT 1
			FROM #tblSpecialEventTemplate AS aa
			WHERE m.OWPMatchId = aa.MinorMatchId
			)

	SET @LoopCounter = 1;

	SELECT @MaxRowCount = COUNT(RowNumber)
	FROM @tblSpecialEventTemplateMain2Minor

	DECLARE @DetectMinorBettypeId INT
		,@MatchNoMinor NVARCHAR(50)

	WHILE (@LoopCounter <= @MaxRowCount)
	BEGIN
		SELECT @LeagueName = LeagueName
			,@HomeName = HomeName
			,@AwayName = AwayName
			,@MinorMatchId = MinorMatchId
		FROM @tblSpecialEventTemplateMain2Minor
		WHERE @LoopCounter = RowNumber

		EXEC [OWP_LiveGameAssignment_DetectMinorMatch] @LeagueName = @LeagueName
			,@HomeName = @HomeName
			,@AwayName = @AwayName
			,@MinorBettypeId = @DetectMinorBettypeId OUTPUT

		SELECT @MatchNoMinor = MatchNo
		FROM dbo.OWPMatch AS m WITH (NOLOCK)
		WHERE m.OWPMatchId = @MinorMatchId

		EXEC dbo.OWP_LiveGameAssignment_EditMainMatchToMinorMatch @OWPMatchId = @MinorMatchId
			,@MinorBettypeId = @DetectMinorBettypeId
			,@ParentMatchId = @OWPMatchId
			,@LeagueName = @LeagueName
			,@HomeName = @HomeName
			,@AwayName = @AwayName
			,@MatchNo = @MatchNoMinor
			,@SessionId = @SessionId
			,@ActorId = @ActorId
			,@ErrCode = @ErrCode OUTPUT
			,@ErrMsg = @ErrMsg OUTPUT

		SET @LoopCounter = @LoopCounter + 1
	END

	SET @LoopCounter = 1
	SET @MaxRowCount = 0;

	SELECT @MaxRowCount = COUNT(RowNumber)
	FROM #tblSpecialEventTemplate

	WHILE (@LoopCounter <= @MaxRowCount)
	BEGIN
		SELECT @LeagueName = LeagueName
			,@HomeName = HomeName
			,@AwayName = AwayName
			,@OWPMatchId = MinorMatchId
			,@MatchNo = MatchNo
			,@MinorBettypeId = MinorBettypeId
		FROM #tblSpecialEventTemplate
		WHERE @LoopCounter = RowNumber

		EXEC dbo.OWP_LiveGameAssignment_EditSingleMatch @OWPMatchId = @OWPMatchId
			,@LeagueName = @LeagueName
			,@HomeName = @HomeName
			,@AwayName = @AwayName
			,@MatchNo = @MatchNo
			,@SessionId = @SessionId
			,@ActorId = @ActorId
			,@KickOffTime = @KickOffTime
			,@MinorBettypeId = @MinorBettypeId
			,@ErrCode = @ErrCode OUTPUT
			,@ErrMsg = @ErrMsg OUTPUT

		SET @LoopCounter = @LoopCounter + 1
	END

	DROP TABLE #tblSpecialEventTemplateMain
	DROP TABLE #tblSpecialEventTemplate
	DROP TABLE #tblOWPMatchByEventDate
	SELECT @ErrCode = 0
		,@ErrMsg = 'The event has been edited successfully!'
END