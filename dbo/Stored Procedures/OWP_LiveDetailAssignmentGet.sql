CREATE PROCEDURE [dbo].[OWP_LiveDetailAssignmentGet] @OWPMatchId INT
AS
/*
Created: 20131031@Julien
Task : get assignment
DB: bodb_OWP

Revisions:
   20170426@Tim.Trinh: fix bug get max bet, spread
   20170728@Tim.Trinh: get bettype name
   20180417@leo.vo: add FM, AIO
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @LeagueId INT
		,@Handicap INT = 1

	SELECT @LeagueId = m.OWPLeagueId
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
	WHERE m.OWPMatchId = @OWPMatchId

	CREATE TABLE #tblTraders (
		UserId INT
		,TraderName NVARCHAR(30)
		,Bettype INT
		,BettypeName VARCHAR(100)
		,AssignmentType INT
		,IsMinor BIT
		)

	-- Main Bet Types
	INSERT INTO #tblTraders (
		UserId
		,TraderName
		,Bettype
		,BettypeName
		,AssignmentType
		,IsMinor
		)
	SELECT a.UserId
		,CASE 
			WHEN ISNULL(u.Nickname, '') <> '' THEN u.Nickname
			ELSE u.Username
			END
		,a.Bettype
		,mbt.[Name]
		,a.AssignmentType
		,0
	FROM dbo.Assignment AS a WITH (NOLOCK)
		INNER JOIN dbo.MajorBettype AS mbt WITH (NOLOCK) ON a.Bettype = mbt.BettypeId
		INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
		LEFT JOIN dbo.MatchBetypeCancel AS mbc WITH (NOLOCK) ON a.OWPMatchId = mbc.OWPMatchId
		AND a.Bettype = mbc.BetType
	WHERE a.OWPMatchId = @OWPMatchId
		AND (a.Bettype > 0 OR a.Bettype IN (-1003, -1004))
		AND a.IsLive = 1

	INSERT INTO #tblTraders (
		Bettype
		,BettypeName
		)
	SELECT DISTINCT bt.BettypeId
		,bt.[Name]
	FROM dbo.MajorBettype AS bt WITH (NOLOCK)
		LEFT JOIN #tblTraders AS t WITH (NOLOCK) ON bt.BettypeId = t.Bettype
	WHERE t.Bettype IS NULL
		AND (bt.BettypeId > 0 OR bt.BettypeId IN (-1003, -1004))

	-- Minor Bet Types
	INSERT INTO #tblTraders (
		UserId
		,TraderName
		,Bettype
		,BettypeName
		,AssignmentType
		,IsMinor
		)
	SELECT a.UserId
		,CASE 
			WHEN ISNULL(u.Nickname, '') <> '' THEN u.Nickname
			ELSE u.Username
			END
		,mb.MinorBettypeId
		,mb.MinorBettypeName
		,a.AssignmentType
		,1
	FROM dbo.MinorMatch AS mm WITH (NOLOCK)
		INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mm.MinorBettypeId = mb.ParentBettypeId
		LEFT JOIN dbo.Assignment AS a WITH (NOLOCK) ON mm.MinorMatchId = a.OWPMatchId
		AND mb.InheritedBettypeId = a.Bettype
		LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
	WHERE mm.IsRepresented = 1
		AND mm.ParentMatchId = @OWPMatchId
		AND mb.InheritedBettypeId > 0

				

	-- get maxbet setting from Parent or Maxbet Management
	CREATE TABLE #tblMaxbetSettingFromParent (
		MinorMatchId INT
		,ParentMinorBettypeId INT
		,MinorBettypeId INT
		,InheritedBettypeId INT
		,Maxbet MONEY
		)

	INSERT INTO #tblMaxbetSettingFromParent (
		MinorMatchId
		,ParentMinorBettypeId
		,MinorBettypeId
		,InheritedBettypeId
		,Maxbet
		)
	SELECT mm.MinorMatchId
		,mm.MinorBettypeId AS ParentMinorBettypeId
		,mb.MinorBettypeId
		,mb.InheritedBettypeId
		,ms.Maxbet
	FROM dbo.MinorMatch AS mm WITH (NOLOCK)
		INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mm.MinorBettypeId = mb.ParentBettypeId
		LEFT JOIN dbo.MatchSetting AS ms WITH (NOLOCK) ON ms.OWPMatchId = @OWPMatchId
		AND ms.Bettype = 1
	WHERE mm.IsRepresented = 1
		AND mm.ParentMatchId = @OWPMatchId

		
	UPDATE #tblMaxbetSettingFromParent WITH (ROWLOCK)
	SET Maxbet = dbo.OWP_MaxBetGet(@OWPMatchId, @LeagueId, @Handicap)
	WHERE InheritedBettypeId > 0
		AND Maxbet IS NULL

	-- Get Minor Bettype Setting
	CREATE TABLE #tblMinorBettypeSetting (
		MinorMatchId INT
		,MinorBettypeId INT
		,InheritedBettypeId INT
		,MaxBet MONEY
		,Spread SMALLMONEY
		)

	INSERT INTO #tblMinorBettypeSetting (
		MinorMatchId
		,MinorBettypeId
		,InheritedBettypeId
		,MaxBet
		,Spread
		)
	SELECT DISTINCT tmp.MinorMatchId
		,tmp.MinorBettypeId
		,tmp.InheritedBettypeId
		,msd.MaxBet / 1000 'MaxBet'
		,msd.Spread * 100 'Spread'
	FROM #tblMaxbetSettingFromParent AS tmp WITH (NOLOCK)
		LEFT JOIN dbo.MinorSetting AS mis WITH (NOLOCK) ON (
			mis.FromMaxBet <= tmp.Maxbet
			AND tmp.Maxbet <= mis.ToMaxBet
			)
		OR (
			mis.FromMaxBet IS NULL
			AND tmp.Maxbet < mis.ToMaxBet
			)
		OR (
			mis.ToMaxBet IS NULL
			AND mis.FromMaxBet < tmp.Maxbet
			)
		LEFT JOIN dbo.MinorSettingDetail AS msd WITH (NOLOCK) ON msd.MinorBettypeId = tmp.ParentMinorBettypeId
		AND msd.MinorSettingId = mis.MinorSettingId

		

	-- Set Maxbet, Spread from MatchSetting if Exist
	UPDATE mbs
	SET mbs.MaxBet = ms.MaxBet / 1000
		,mbs.Spread = ms.Spread * 100
	FROM #tblMinorBettypeSetting AS mbs WITH (ROWLOCK)
		INNER JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON mbs.MinorMatchId = mm.MinorMatchId
		AND mm.ParentMatchId = @OWPMatchId
		AND mm.IsRepresented = 1
		INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mm.MinorBettypeId = mb.ParentBettypeId
		AND mbs.InheritedBettypeId = mb.InheritedBettypeId
		INNER JOIN dbo.MatchSetting AS ms WITH (NOLOCK) ON mm.MinorMatchId = ms.OWPMatchId
		AND ms.Bettype = mbs.InheritedBettypeId

	-- select match setting
	CREATE TABLE #tblMatchSetting (
		Bettype INT
		,MinorMatchId INT
		,InheritedBettypeId INT
		,BettypeName VARCHAR(100)
		,MaxBet MONEY
		,Spread SMALLMONEY
		,IsCancelled BIT
		,NoOfHDP INT
		)

	INSERT INTO #tblMatchSetting (
		Bettype
		,BettypeName
		,MaxBet
		,Spread
		,IsCancelled
		,NoOfHDP
		)
	SELECT t.Bettype
		,t.BettypeName
		,t.MaxBet
		,t.Spread
		,t.IsCancelled
		,t.NoOfHDP
	FROM (
		SELECT DISTINCT t.Bettype
			,t.BettypeName
			,ms.Maxbet / 1000 'MaxBet'
			,ms.Spread * 100 'Spread'
			,CASE 
				WHEN mbc.OWPMatchId IS NULL THEN 0
				ELSE 1
				END 'IsCancelled'
			,mbh.Handicap AS NoOfHDP
		FROM #tblTraders AS t WITH (NOLOCK)
			LEFT JOIN dbo.MatchBetypeCancel AS mbc WITH (NOLOCK) ON mbc.OWPMatchId = @OWPMatchId
			AND t.Bettype = mbc.BetType
			LEFT JOIN dbo.MatchSetting AS ms WITH (NOLOCK) ON ms.OWPMatchId = @OWPMatchId
			AND ms.Bettype = t.Bettype
			LEFT JOIN dbo.MatchBettypeHDP AS mbh WITH (NOLOCK) ON mbh.OWPMatchId = @OWPMatchId
			AND mbh.Bettype = t.Bettype
		) t

		

	UPDATE ms
	--SET ms.MaxBet = CASE 
	--		WHEN ms.MaxBet IS NULL THEN dbo.OWP_MaxBetGet(@OWPMatchId, @LeagueId, ms.Bettype) / 1000
	--		ELSE ms.MaxBet
	--		END
	--	,ms.Spread = CASE 
	--		WHEN ms.Spread IS NULL THEN dbo.OWP_SpreadGet(@OWPMatchId, @LeagueId, ms.Bettype) * 100
	--		ELSE ms.Spread
	--		END
	SET ms.MaxBet = dbo.OWP_MaxBetGet(@OWPMatchId, @LeagueId, ms.Bettype) / 1000
		,ms.Spread = dbo.OWP_SpreadGet(@OWPMatchId, @LeagueId, ms.Bettype) * 100
	FROM #tblMatchSetting AS ms WITH (ROWLOCK)
	WHERE ms.MaxBet IS NULL
		AND ms.Spread IS NULL

	UPDATE ms
	SET ms.MaxBet = mbs.MaxBet
		,ms.Spread = mbs.Spread
		,ms.InheritedBettypeId = mbs.InheritedBettypeId
		,ms.MinorMatchId = mbs.MinorMatchId
	FROM #tblMatchSetting AS ms WITH (ROWLOCK)
		INNER JOIN #tblMinorBettypeSetting AS mbs WITH (NOLOCK) ON mbs.MinorBettypeId = ms.Bettype

	--
	SELECT Bettype
		,MinorMatchId
		,InheritedBettypeId
		,BettypeName
		,MaxBet
		,Spread
		,IsCancelled
		,NoOfHDP
	FROM #tblMatchSetting WITH (NOLOCK)
	ORDER BY (CASE 
			WHEN Bettype IN (1, 3, 7, 8) THEN 5
			WHEN Bettype IN (5) THEN 4
			WHEN Bettype IN (15) THEN 3
			WHEN Bettype IN (-1003, -1004) THEN 2
			WHEN Bettype < 0 THEN 1
			ELSE 0 END
			) DESC
		,(CASE 
			WHEN Bettype < 0 THEN Bettype
			ELSE 0 END
			) DESC

	SELECT t.UserId
		,t.Bettype
		,t.AssignmentType
		,t.IsMinor
	FROM #tblTraders AS t WITH (NOLOCK)
	WHERE t.UserId IS NOT NULL
	ORDER BY t.AssignmentType

	SELECT t.UserId
		,t.TraderName AS Username
		,u.Skype
		,u.Extension
		,u.Phone
		,u.LocationCode
	FROM (
		SELECT DISTINCT t.UserId
			,t.TraderName
		FROM #tblTraders AS t WITH (NOLOCK)
		WHERE t.UserId IS NOT NULL
		) t
		LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON t.UserId = u.UserId

	DROP TABLE #tblTraders

	DROP TABLE #tblMinorBettypeSetting

	DROP TABLE #tblMatchSetting

	DROP TABLE #tblMaxbetSettingFromParent
END