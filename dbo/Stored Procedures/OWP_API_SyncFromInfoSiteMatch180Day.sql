USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_API_SyncFromInfoSiteMatch180Day]    Script Date: 01/06/2021 10:51:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_API_SyncFromInfoSiteMatch180Day] @InfoSiteMatchResultDoc NVARCHAR(MAX)
AS
/*    
 Created: 20201125@Carlos.nguyen
 Task : SyncFromInfoSiteMatch180Day
 DB: bodb_OWP    
    
 Revisions:
	20201125@Carlos.nguyen: Initial SP - [Redmine: #145592]
	20210106@Carlos.nguyen:  Enhance insert data NULL for Early Matches - [Redmine: #148284]
	=> This enhance to fix agent.split object not set reference in case event upload
	20210128@CarlosNguyen: Sync MatchCode - [Redmine: #149347]
	20220224@tyler: upgrade XML package - [Redmine: #168050]   
	20250522@Frankie: Not update KO time - [Redmine: #228288]   
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @idoc INT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@InfoSiteMatchResultDoc

	CREATE TABLE #tblInfoSiteMatch (
		 [MatchId] [INT] NOT NULL
		,[KOTime] [datetime] NOT NULL
		,[LeagueName] [nvarchar](500) NOT NULL
		,[HomeName] [nvarchar](200) NOT NULL
		,[AwayName] [nvarchar](200) NOT NULL
		,[AdminSiteId] INT NULL
		,[UpdatedTime] [datetime] NOT NULL
		,[OWPLeagueId] INT
		,[OWPHomeId] INT
		,[OWPAwayId] INT
		,[IsNeutral] BIT
		)

	INSERT INTO #tblInfoSiteMatch (
		 [MatchId]
		,[KOTime]
		,[LeagueName]
		,[HomeName]
		,[AwayName]
		,[AdminSiteId]
		,[UpdatedTime]
		,[IsNeutral]
		)
	SELECT[MatchId]
		,[KOTime]
		,[LeagueName]
		,[HomeName]
		,[AwayName]
		,[AdminSiteId]
		,[UpdatedTime]
		,[IsNeutral]
	FROM OPENXML(@idoc, '/Root/MatchModelFor180Day', 1) WITH (
			[MatchId] [INT]
			,[KOTime] DATETIME
			,[LeagueName] NVARCHAR(500)
			,[HomeName] NVARCHAR(200)
			,[AwayName] NVARCHAR(200)
			,[AdminSiteId][INT]
			,[UpdatedTime] DATETIME
			,[IsNeutral] BIT
			)

	EXEC sp_xml_removedocument @idoc
	
	-- 1. insert new league
	INSERT INTO dbo.OWPLeague (OWPLeagueName)
	SELECT DISTINCT im.LeagueName
	FROM #tblInfoSiteMatch AS im
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.OWPLeague AS l WITH (NOLOCK)
			WHERE im.LeagueName = l.OWPLeagueName
			)

	-- 2. update OWPLeagueId
	UPDATE im
	SET im.OWPLeagueId = l.OWPLeagueId
	FROM #tblInfoSiteMatch AS im
	INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON im.LeagueName = l.OWPLeagueName
	
	-- 3.insert new team
	INSERT INTO dbo.OWPTeam (OWPTeamName)
	SELECT im.TeamName
	FROM (
		SELECT im.HomeName AS TeamName
		FROM #tblInfoSiteMatch AS im
		
		UNION
		
		SELECT im.AwayName AS TeamName
		FROM #tblInfoSiteMatch AS im
		) AS im
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.OWPTeam AS t WITH (NOLOCK)
			WHERE im.TeamName = t.OWPTeamName
			)

	-- 4.update OWPHomeId
	UPDATE im
	SET im.OWPHomeId = t.OWPTeamId
	FROM #tblInfoSiteMatch AS im
	INNER JOIN dbo.OWPTeam AS t WITH (NOLOCK) ON im.HomeName = t.OWPTeamName

	-- 5.update OWPAwayId
	UPDATE im
	SET im.OWPAwayId = t.OWPTeamId
	FROM #tblInfoSiteMatch AS im
	INNER JOIN dbo.OWPTeam AS t WITH (NOLOCK) ON im.AwayName = t.OWPTeamName
	
	-- 6.1 update match info exists
	-- Update exists infosite match
	UPDATE im
	SET im.LeagueName=tblim.LeagueName,
		im.HomeName=tblim.HomeName,
		im.AwayName=tblim.AwayName,
		im.AdminSiteMatchId=tblim.AdminSiteId,
		im.OWPLeagueId=tblim.OWPLeagueId,
		im.OWPHomeId=tblim.OWPHomeId,
		im.OWPAwayId=tblim.OWPAwayId
	FROM InfoSiteMatch AS im WITH(ROWLOCK)
	INNER JOIN #tblInfoSiteMatch AS tblim WITH (NOLOCK) ON tblim.MatchId=im.InfoSiteMatchId
	
	-- 6.2 insert new infosite match
	INSERT INTO InfoSiteMatch
	(
		OWPLeagueId,
		OWPHomeId,
		OWPAwayId,
		InfoSiteMatchId,
		EventDateTime,
		LeagueName,
		HomeName,
		AwayName,
		AdminSiteMatchId,
		UpdatedTime,
		IsNeutral,
		[Round],
		Division,
		Agent,
		TV,
		Channel,
		WB,
		Website1,
		Website2,
		Website3,
		Website4,
		IPTV,
		ETPK,
		MatchCode
	)
	SELECT 
		tblim.OWPLeagueId,
		tblim.OWPHomeId,
		tblim.OWPAwayId,
		tblim.MatchId,
		tblim.KOTime,
		tblim.LeagueName,
		tblim.HomeName,
		tblim.AwayName,
		tblim.AdminSiteId,
		tblim.UpdatedTime,
		tblim.IsNeutral,
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		''
	FROM #tblInfoSiteMatch AS tblim
	WHERE NOT EXISTS (
			SELECT 1
			FROM InfoSiteMatch AS im WITH (NOLOCK)
			WHERE im.InfoSiteMatchId = tblim.MatchId
			)

	DROP TABLE #tblInfoSiteMatch

END