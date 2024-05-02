
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_TVSSupport_GetIptvInfo] @MatchInfoJson NVARCHAR(MAX)

AS

/*
Created: 20240419@Johnny
Task : Get info
DB: bodb_OWP

Revisions:
	20240419@Johnny: Initial - [Redmine: #204111]
*/

    BEGIN
        SET NOCOUNT ON;
		DECLARE @FlagDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, getDate()) - 35, '11:59:59');
		DECLARE @MatchResult TABLE
		(MatchId			INT,
		 Iptv				NVARCHAR(100),
		 Tv					NVARCHAR(100),
		 EventDateTime		DATE
		);
		-- Handle json input
        DECLARE @Temp TABLE
        (MatchId   INT, 
         EventDate DATETIME
        );
        INSERT INTO @Temp(MatchId, EventDate)
        SELECT MatchId, 
               EventDate
        FROM OPENJSON(@MatchInfoJson) WITH(MatchId INT, EventDate DATETIME);
		--Get data from OWPMatch
		DECLARE @MatchBiggerFlagDateTime TABLE(AdminSiteMatchId INT, OWPMatchId INT, EventDateTime DATE)
		INSERT INTO @MatchBiggerFlagDateTime(AdminSiteMatchId, OWPMatchId, EventDateTime)
		SELECT	t.MatchId,
				m.OWPMatchId,
				m.EventDateTime
		FROM @Temp AS t
			LEFT JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON t.MatchId = m.MatchId AND t.EventDate = CAST(DATEADD(HOUR, -12, m.EventDateTime) AS DATE)
		WHERE m.EventDateTime > @FlagDateTime
		--Get data from OWPMatch_Old
        DECLARE @MatchSmallerFlagDateTime TABLE(AdminSiteMatchId INT, OWPMatchId INT, EventDateTime DATE)
		INSERT INTO @MatchSmallerFlagDateTime(AdminSiteMatchId, OWPMatchId, EventDateTime)
		SELECT	t.MatchId,
				mo.OWPMatchId,
				mo.EventDateTime
		FROM @Temp AS t
			LEFT JOIN dbo.OWPMatch_Old AS mo WITH (NOLOCK) ON t.MatchId = mo.MatchId AND t.EventDate = CAST(DATEADD(HOUR, -12, mo.EventDateTime) AS DATE)
		WHERE mo.EventDateTime < @FlagDateTime

		INSERT @MatchResult(MatchId, Iptv, Tv, EventDateTime)
		SELECT	mb.AdminSiteMatchId,
				mi.IPTV,
				(
					SELECT STRING_AGG(tv.TVCode, ', ')
					FROM dbo.Television AS tv WITH(NOLOCK)
						 INNER JOIN dbo.MatchTelevision AS mt WITH(NOLOCK) ON tv.TVId = mt.TVId
					WHERE mb.OWPMatchId = mt.OWPMatchId
				),
				mb.EventDateTime
		FROM @MatchBiggerFlagDateTime as mb 
			LEFT JOIN dbo.MatchInfo as mi WITH (NOLOCK) ON mb.OWPMatchId = mi.OWPMatchId

		INSERT @MatchResult(MatchId, Iptv, Tv, EventDateTime)
		SELECT	ms.AdminSiteMatchId,
				mio.IPTV,
				(
					SELECT STRING_AGG(tv.TVCode, ', ')
					FROM dbo.Television AS tv WITH(NOLOCK)
						 INNER JOIN dbo.MatchTelevision_Old AS mto WITH(NOLOCK) ON tv.TVId = mto.TVId
					WHERE ms.OWPMatchId = mto.OWPMatchId
				),
				ms.EventDateTime
		FROM @MatchSmallerFlagDateTime as ms 
			LEFT JOIN dbo.MatchInfo_Old as mio WITH (NOLOCK) ON ms.OWPMatchId = mio.OWPMatchId

		SELECT	MatchId,
				Iptv,
				Tv
		FROM (
				SELECT MatchId, Iptv, Tv,
					   ROW_NUMBER() OVER (PARTITION BY MatchId ORDER BY EventDateTime DESC) AS row_num
				FROM @MatchResult
			 ) AS ranked
		WHERE row_num = 1
    END;