/*
	Creator:	20181009@Leo
	Task:		Data migration for new OWP - Match - League - Team - Assignment tables - [Redmine: #102733]
	Server:		DBOWP.bodb_OWP

	Review & Tested:	Billy
*/


DECLARE @FastMarket		INT = -88
	,	@AllInOne		INT = -89
	;

CREATE TABLE	#tblMigratedMatch (
					OWPMatchId		INT
				);

CREATE TABLE	#tblNewMinorMatch (
					MinorBettypeId	INT
				,	League			NVARCHAR(2000)
				,	Home			NVARCHAR(2000)
				,	Away			NVARCHAR(2000)
				,	OWPLeagueId		INT
				,	OWPHomeId		INT
				,	OWPAwayId		INT
				,	ParentMatchId	INT
				);

CREATE TABLE	#tblInsertedMinorMatch (
					OWPMatchId		INT
				,	MinorBettypeId	INT
				,	ParentMatchId	INT
				);

-- 45469 rows affected --
INSERT INTO	#tblMigratedMatch (OWPMatchId)
SELECT	mi.OWPMatchId
FROM		dbo.MatchInfo_Old AS mi WITH (NOLOCK)
INNER JOIN	dbo.OWPMatch_Old AS om WITH (NOLOCK)
		ON	mi.OWPMatchId = om.OWPMatchId
LEFT JOIN	dbo.MinorMatch_Old AS mm WITH (NOLOCK)
		ON	mi.OWPMatchId = mm.MinorMatchId
WHERE	om.EventDate >= '2018-06-01 00:00:00.000'
	AND	ISNULL(mm.MinorBettypeId, 0) NOT IN (-9, -10, -41, -42, -43, -44);

--Migrate data into table MatchInfo
-- 45469 rows affected --
INSERT INTO dbo.MatchInfo
	(	OWPMatchId, NoOfHDP, Channel, WB, Provider, Runner, Phone, KOTimeRemark, ExtraTimeRemark, Venue, TVCode, LocalTV, LiveTV, Agent
	,	IsSelectedUpdatedDate, IsSelected, SelectedBy, IsSoloMatch, Round, Division, Remark, Website1, Website2, Website3, Website4, MatchStatus)
SELECT	[OWPMatchId]			= match.OWPMatchId
	,	[NoOfHDP]				= mi.NoOfHDP
	,	[Channel]				= mi.Channel
	,	[WB]					= mi.WatchBet
	,	[Provider]				= mi.Provider
	,	[Runner]				= mi.Runner
	,	[Phone]					= mi.Phone
	,	[KOTimeRemark]			= mi.KOTimeRemark
	,	[ExtraTimeRemark]		= mi.ExtraTimeRemark
	,	[Venue]					= mi.Venue
	,	[TVCode]				= STUFF(	(	SELECT	',' + ISNULL(CAST(tv.TVId AS VARCHAR), '')
												FROM		dbo.Television AS tv WITH (NOLOCK)
												CROSS APPLY	dbo.fnc_SplitStrings(mi.TVCode, ',') AS f
												WHERE RTRIM(LTRIM(REPLACE(REPLACE(f.val, CHAR(13), ''), CHAR(10), ''))) = tv.TVCode
												FOR XML PATH('')
											)
								  , 1, 1, '')
	,	[LocalTV]				= mi.LocalTV
	,	[LiveTV]				= mi.LiveTV
	,	[Agent]					= mi.Agent
	,	[IsSelectedUpdatedDate]	= mi.IsSelectedUpdatedDate
	,	[IsSelected]			= mi.IsSelected
	,	[SelectedBy]			= mi.SelectedBy
	,	[IsSoloMatch]			= mi.IsSoloMatch
	,	[Round]					= mi.Round
	,	[Division]				= mi.OutSide
	,	[Remark]				= mi.Remark
	,	[Website1]				= mi.Website
	,	[Website2]				= mi.Website2
	,	[Website3]				= mi.Website3
	,	[Website4]				= mi.Website4
	,	[MatchStatus]			= mi.MatchStatus
FROM		#tblMigratedMatch AS match WITH (NOLOCK)
INNER JOIN	dbo.MatchInfo_Old AS mi WITH (NOLOCK)
		ON	match.OWPMatchId = mi.OWPMatchId;

--Migrate data into table OWPMatch
SET IDENTITY_INSERT dbo.OWPMatch ON;
-- 45469 rows affected --
INSERT INTO	dbo.OWPMatch (OWPMatchId, MatchNo, EventDate, KickOffTime, OWPLeagueId, OWPHomeId, OWPAwayId, MatchId, OtherTime, EventDateTime, InfositeMatchKey)
SELECT	[OWPMatchId]		= match.OWPMatchId
	,	[MatchNo]			= om.MatchNo
	,	[EventDate]			= om.EventDate
	,	[KickOffTime]		= om.KickOffTime
	,	[OWPLeagueId]		= om.OWPLeagueId
	,	[OWPHomeId]			= om.OWPHomeId
	,	[OWPAwayId]			= om.OWPAwayId
	,	[MatchId]			= om.MatchId
	,	[OtherTime]			= om.OtherTime
	,	[EventDateTime]		= om.EventDateTime
	,	[InfositeMatchKey]	= om.InfoSiteMatchKey
FROM		#tblMigratedMatch AS match WITH (NOLOCK)
INNER JOIN	dbo.OWPMatch_Old AS om WITH (NOLOCK)
		ON	match.OWPMatchId = om.OWPMatchId;
SET IDENTITY_INSERT dbo.OWPMatch OFF;

-- Migrate data into table MInorMatch
-- 6726 rows affected --
INSERT INTO	dbo.MinorMatch (MinorMatchId, ParentMatchId, MinorBettypeId, IsRepresented)
SELECT	[MinorMatchId]		= mm.MinorMatchId
	,	[ParentMatchId]		= mm.ParentMatchId
	,	[MinorBettypeId]	= mm.MinorBettypeId
	,	[IsRepresented]		= mm.IsRepresented
FROM		#tblMigratedMatch AS match WITH (NOLOCK)
INNER JOIN	dbo.MinorMatch_Old AS mm WITH (NOLOCK)
		ON	match.OWPMatchId = mm.MinorMatchId;

--Create new Minor match FM & ALLInOne
-- 77486 rows affected --
INSERT INTO	#tblNewMinorMatch (MinorBettypeId, League, Home, Away, ParentMatchId)
SELECT	[MinorBettypeId]	= @FastMarket
	,	[League]			= REPLACE(t.League, '<name>', l.OWPLeagueName)
	,	[Home]				= REPLACE(t.Home, '<name>', home.OWPTeamName)
	,	[Away]				= REPLACE(t.Away, '<name>', away.OWPTeamName)
	,	[ParentMatchId]		= om.OWPMatchId
FROM		dbo.OWPMatch AS om WITH (NOLOCK)
LEFT JOIN	dbo.OWPLeague AS l WITH (NOLOCK)
		ON	om.OWPLeagueId = l.OWPLeagueId
LEFT JOIN	dbo.OWPTeam AS home WITH (NOLOCK)
		ON	om.OWPHomeId = home.OWPTeamId
LEFT JOIN	dbo.OWPTeam AS away WITH (NOLOCK)
		ON	om.OWPAwayId = away.OWPTeamId
INNER JOIN	dbo.MinorMatchTemplateSetting AS t WITH (NOLOCK)
		ON	t.MinorBettypeId = @FastMarket
LEFT JOIN	dbo.MinorMatch_Old AS mm WITH (NOLOCK)
		ON	om.OWPMatchId = mm.MinorMatchId
WHERE	mm.MinorBettypeId IS NULL
UNION
SELECT	[MinorBettypeId]	= @AllInOne
,		[League]			= REPLACE(t.League, '<name>', l.OWPLeagueName)
,		[Home]				= REPLACE(t.Home, '<name>', home.OWPTeamName)
,		[Away]				= REPLACE(t.Away, '<name>', away.OWPTeamName)
,		[ParentMatchId]		= om.OWPMatchId
FROM		dbo.OWPMatch AS om WITH (NOLOCK)
LEFT JOIN	dbo.OWPLeague AS l WITH (NOLOCK)
		ON	om.OWPLeagueId = l.OWPLeagueId
LEFT JOIN	dbo.OWPTeam AS home WITH (NOLOCK)
		ON	om.OWPHomeId = home.OWPTeamId
LEFT JOIN	dbo.OWPTeam AS away WITH (NOLOCK)
		ON	om.OWPAwayId = away.OWPTeamId
INNER JOIN	dbo.MinorMatchTemplateSetting AS t WITH (NOLOCK)
		ON	t.MinorBettypeId = @AllInOne
LEFT JOIN	dbo.MinorMatch_Old AS mm WITH (NOLOCK)
		ON	om.OWPMatchId = mm.MinorMatchId
WHERE	mm.MinorBettypeId IS NULL;

--insert owpLeague, OwpTeam
-- 2160 rows affected --
INSERT INTO	dbo.OWPLeague (OWPLeagueName, IsActive)
SELECT	DISTINCT
		[OWPLeagueName]		= mm.League
	,	[IsActive]			= 1
FROM	#tblNewMinorMatch AS mm WITH (NOLOCK)
WHERE	NOT EXISTS (SELECT 1 FROM dbo.OWPLeague AS ol WITH (NOLOCK) WHERE ol.OWPLeagueName = mm.League);

--insert OwpTeam
-- 28514 rows affected --
INSERT INTO	dbo.OWPTeam (OWPTeamName)
SELECT	t.TeamName
FROM	(
	SELECT	[TeamName]	= Home
	FROM	#tblNewMinorMatch WITH (NOLOCK)
	UNION
	SELECT	[TeamName]	= Away
	FROM	#tblNewMinorMatch WITH (NOLOCK)
) AS t
WHERE	NOT EXISTS (SELECT 1 FROM dbo.OWPTeam AS ot WITH (NOLOCK) WHERE ot.OWPTeamName = t.TeamName);

-- update OWPLeagueId, OWPHomeId, OWPAwayId
-- 77486 rows affected --
UPDATE	mm WITH (TABLOCK)
SET		mm.OWPLeagueId	= l.OWPLeagueId
	,	mm.OWPHomeId	= h.OWPTeamId
	,	mm.OWPAwayId	= a.OWPTeamId
FROM		#tblNewMinorMatch AS mm
INNER JOIN	dbo.OWPLeague AS l WITH (NOLOCK)
		ON	mm.League = l.OWPLeagueName
INNER JOIN	dbo.OWPTeam AS h WITH (NOLOCK)
		ON	mm.Home = h.OWPTeamName
INNER JOIN	dbo.OWPTeam AS a WITH (NOLOCK)
		ON	mm.Away = a.OWPTeamName;

-- Insert new minor matches into OWPMatch
-- 77486 rows affected --
MERGE INTO	dbo.OWPMatch WITH (TABLOCK) AS om
USING	(
	SELECT	om.EventDate
		,	om.KickOffTime
		,	mm.OWPLeagueId
		,	mm.OWPHomeId
		,	mm.OWPAwayId
		,	om.OtherTime
		,	om.EventDateTime
		,	mm.MinorBettypeId
		,	mm.ParentMatchId
	FROM		#tblNewMinorMatch AS mm WITH (NOLOCK)
	INNER JOIN	dbo.OWPMatch AS om WITH (NOLOCK)
			ON	mm.ParentMatchId = om.OWPMatchId
) AS mat
	ON	1 = 0
WHEN NOT MATCHED THEN
	INSERT	(EventDate, KickOffTime, OWPLeagueId, OWPHomeId, OWPAwayId, OtherTime, EventDateTime)
	VALUES	(mat.EventDate, mat.KickOffTime, mat.OWPLeagueId, mat.OWPHomeId, mat.OWPAwayId, mat.OtherTime, mat.EventDateTime)
OUTPUT	inserted.OWPMatchId
	,	mat.MinorBettypeId
	,	mat.ParentMatchId
INTO	#tblInsertedMinorMatch (OWPMatchId, MinorBettypeId, ParentMatchId);

-- Insert new minor matches into MatchInfo
-- 77486 rows affected --
INSERT INTO	dbo.MatchInfo (OWPMatchId, IsSelectedUpdatedDate, IsSelected, SelectedBy, IsSoloMatch, MatchStatus)
SELECT	[OWPMatchId]			= im.OWPMatchId
,		[IsSelectedUpdatedDate]	= info.IsSelectedUpdatedDate
,		[IsSelected]			= info.IsSelected
,		[SelectedBy]			= info.SelectedBy
,		[IsSoloMatch]			= info.IsSoloMatch
,		[MatchStatus]			= info.MatchStatus
FROM		#tblInsertedMinorMatch AS im WITH (NOLOCK)
INNER JOIN	dbo.MatchInfo AS info WITH (NOLOCK)
		ON	im.ParentMatchId = info.OWPMatchId;

-- Insert new minor matches into MinorMatch
-- 77486 rows affected --
INSERT INTO	dbo.MinorMatch (MinorMatchId, ParentMatchId, MinorBettypeId, IsRepresented)
SELECT	[MinorMatchId]			= im.OWPMatchId
	,	[ParentMatchId]			= im.ParentMatchId
	,	[MinorBettypeId]		= im.MinorBettypeId
	,	[IsRepresented]			= 1
FROM	#tblInsertedMinorMatch AS im;

--/*Migrate Assignment*/
DECLARE @BettypeHDP				INT = 1
	,	@BettypeOU				INT = 3
	,	@MainAssignmentType		INT = 1
	,	@OtherAssignmentType	INT = 2
	;

--Insert assignment of main match
-- 172540 rows affected --
INSERT INTO	dbo.Assignment (OWPMatchId, Bettype, AssignmentType, UserId, AssignmentNote)
SELECT	DISTINCT
		[OWPMatchId]			= match.OWPMatchId
,		[Bettype]				= CASE WHEN a.Bettype = -1002 OR a.Bettype = -1001 THEN -1002 ELSE a.Bettype END
,		[AssignmentType]		= CASE WHEN a.Bettype = -1002 THEN @OtherAssignmentType ELSE @MainAssignmentType END
,		[UserId]				= a.UserId
,		[AssignmentNote]		= CASE WHEN a.Bettype = -1002 THEN '#<user> 2H' ELSE NULL END
FROM		#tblMigratedMatch AS match WITH (NOLOCK)
LEFT JOIN	dbo.MinorMatch_Old AS mm WITH (NOLOCK)
		ON	match.OWPMatchId = mm.MinorMatchId
LEFT JOIN	dbo.Assignment_Old AS a WITH (NOLOCK)
		ON	match.OWPMatchId = a.OWPMatchId
WHERE	a.AssignmentType = 1
	AND	mm.MinorBettypeId IS NULL
	AND	a.Bettype NOT IN (-1003, -1004);

--Insert assignment of 15mins, 10mins, 15mins NoOfCorners, 15mins TOtal booking match
-- 1896 rows affected --
INSERT INTO	dbo.Assignment (OWPMatchId, Bettype, AssignmentType, UserId, AssignmentNote)
SELECT	DISTINCT
		[OWPMatchId]			= match.OWPMatchId
	,	[Bettype]				= CASE WHEN a.Bettype = @BettypeOU THEN @BettypeHDP ELSE a.Bettype END
	,	[AssignmentType]		= CASE WHEN a.Bettype = @BettypeOU THEN @OtherAssignmentType ELSE @MainAssignmentType END
	,	[UserId]				= a.UserId
	,	[AssignmentNote]		= CASE WHEN a.Bettype = @BettypeOU THEN '#<user> O/U' ELSE NULL END
FROM		#tblMigratedMatch AS match WITH (NOLOCK)
INNER JOIN	dbo.MinorMatch_Old AS mm WITH (NOLOCK)
		ON	match.OWPMatchId = mm.MinorMatchId
LEFT JOIN	dbo.Assignment_Old AS a WITH (NOLOCK)
		ON	match.OWPMatchId = a.OWPMatchId
WHERE	a.AssignmentType = 1
	AND	mm.MinorBettypeId IN (-1, -2, -5, -8)
	AND	a.Bettype NOT IN (-1001, -1002);

--Insert assignment of remains minor match
-- 8505 rows affected --
INSERT INTO	dbo.Assignment (OWPMatchId, Bettype, AssignmentType, UserId, AssignmentNote)
SELECT	DISTINCT
		[OWPMatchId]			= match.OWPMatchId
	,	[Bettype]				= CASE WHEN a.Bettype = -1002 OR a.Bettype = -1001 THEN -1002 ELSE a.Bettype END
	,	[AssignmentType]		= CASE WHEN a.Bettype = -1002 THEN @OtherAssignmentType ELSE @MainAssignmentType END
	,	[UserId]				= a.UserId
	,	[AssignmentNote]		= CASE WHEN a.Bettype = -1002 THEN '#<user> 2H' ELSE NULL END
FROM		#tblMigratedMatch AS match WITH (NOLOCK)
INNER JOIN	dbo.MinorMatch_Old AS mm WITH (NOLOCK)
		ON	match.OWPMatchId = mm.MinorMatchId
LEFT JOIN	dbo.Assignment_Old AS a WITH (NOLOCK)
		ON	match.OWPMatchId = a.OWPMatchId
WHERE	a.AssignmentType = 1
	AND	ISNULL(mm.MinorBettypeId, 0) NOT IN (0, -1, -2, -5, -8)
	AND	a.Bettype NOT IN (5, 15)
	AND	(	(	mm.MinorBettypeId IN (-4, -7)
			AND	a.Bettype NOT IN (-1001, -1002)
			)
		OR	(	mm.MinorBettypeId NOT IN (-4, -7)
			AND	a.Bettype IN (1, 3, 7, 8, -1001, -1002)
			)
		);

--Insert assignment of FM, AIO
-- 20173 rows affected --
INSERT INTO	dbo.Assignment (OWPMatchId, Bettype, AssignmentType, UserId, AssignmentNote)
SELECT	[OWPMatchId]			= im.OWPMatchId
	,	[Bettype]				= @BettypeHDP
	,	[AssignmentType]		= @MainAssignmentType
	,	[UserId]				= a.UserId
	,	[AssignmentNote]		= NULL
FROM		#tblInsertedMinorMatch AS im WITH (NOLOCK)
INNER JOIN	dbo.Assignment_Old AS a WITH (NOLOCK)
		ON	im.ParentMatchId = a.OWPMatchId
		AND a.Bettype = CASE WHEN im.MinorBettypeId = @FastMarket THEN -1003 WHEN im.MinorBettypeId = @AllInOne THEN -1004 END;


--/*Migrate table MatchSetting*/
-- 75768 rows affected --
INSERT INTO	dbo.MatchSetting (OWPMatchId, Bettype, Spread, Maxbet)
SELECT	[OWPMatchId]			= match.OWPMatchId
	,	[Bettype]				= ms.Bettype
	,	[Spread]				= ms.Spread
	,	[Maxbet]				= ms.Maxbet
FROM		#tblMigratedMatch AS match WITH (NOLOCK)
INNER JOIN	dbo.MatchSetting_Old AS ms WITH (NOLOCK)
		ON	match.OWPMatchId = ms.OWPMatchId;

--rename home, away name of 10mins 15mins
-- 75768 rows affected --
UPDATE	dbo.OWPTeam WITH (TABLOCK)
SET		OWPTeamName = REPLACE(OWPTeamName, '00:00-15:00', '(SPECIFIC 15 MINS)')
WHERE	OWPTeamName LIKE '%00:00-15:00%';

-- 46 rows affected --
UPDATE	dbo.OWPTeam WITH (TABLOCK)
SET		OWPTeamName = REPLACE(OWPTeamName, '00:00-10:00', '(SPECIFIC 10 MINS)')
WHERE	OWPTeamName LIKE '%00:00-10:00%';


DROP TABLE #tblMigratedMatch;
DROP TABLE #tblNewMinorMatch;
DROP TABLE #tblInsertedMinorMatch;