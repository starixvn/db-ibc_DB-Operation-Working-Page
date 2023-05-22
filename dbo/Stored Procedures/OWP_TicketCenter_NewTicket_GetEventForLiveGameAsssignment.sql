
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_NewTicket_GetEventForLiveGameAsssignment] @Keyword NVARCHAR(500)
AS

/*      
 Created: 20220216@Johnny
 Task : Get event option
 DB: bodb_OWP      
      
 Revisions:          
	20220929@Johnny: Init sp - [Redmine: #178183]
	20230522@Johnny: Edit date range to get event data - [Redmine: #188585]

*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @date DATETIME;
        DECLARE @startDate DATETIME;
        SELECT @date = CAST(CAST(GETDATE() AS DATE) AS DATETIME);
        SELECT @startDate = DATEADD(HOUR, 12, CONVERT(DATETIME, @date));
        DECLARE @tblOWPMatchHomeName TABLE
        (OWPMatchId INT, 
         HomeName   NVARCHAR(MAX)
        );
        INSERT INTO @tblOWPMatchHomeName
        (OWPMatchId, 
         HomeName
        )
               SELECT m.OWPMatchId, 
                      t.OWPTeamName
               FROM OWPMatch AS m
                    INNER JOIN OWPTeam AS t WITH(NOLOCK) ON m.OWPHomeId = t.OWPTeamId;
        DECLARE @tblOWPMatchAwayName TABLE
        (OWPMatchId INT, 
         AwayName   NVARCHAR(MAX)
        );
        INSERT INTO @tblOWPMatchAwayName
        (OWPMatchId, 
         AwayName
        )
               SELECT m.OWPMatchId, 
                      t.OWPTeamName
               FROM OWPMatch AS m
                    INNER JOIN OWPTeam AS t WITH(NOLOCK) ON m.OWPAwayId = t.OWPTeamId;
        DECLARE @tblEventOption TABLE
        (OwpMatchId        INT, 
         OwpLeagueId       INT, 
         LeagueName        NVARCHAR(MAX), 
         HomeName          NVARCHAR(MAX), 
         AwayName          NVARCHAR(MAX), 
         HomeId            INT, 
         AwayId            INT, 
         EventDateTimeGmt8 DATETIME, 
         IsLeague          BIT,
		 MinorBettype INT
        );

        INSERT INTO @tblEventOption
        (OwpLeagueId, 
         HomeName, 
         AwayName, 
         HomeId, 
         AwayId, 
         OwpMatchId, 
         LeagueName, 
         IsLeague, 
         EventDateTimeGmt8,
		 MinorBettype
        )
               SELECT m.OWPLeagueId, 
                      hn.HomeName, 
                      an.AwayName, 
                      m.OWPHomeId, 
                      m.OWPAwayId, 
                      m.OWPMatchId, 
                      l.OWPLeagueName, 
                      0, 
                      m.EventDateTime,
					  mm.MinorBettypeId
               FROM OWPMatch AS m WITH(NOLOCK)
                    INNER JOIN OWPLeague AS l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
                    INNER JOIN @tblOWPMatchHomeName AS hn ON hn.OWPMatchId = m.OWPMatchId
                    INNER JOIN @tblOWPMatchAwayName AS an ON an.OWPMatchId = m.OWPMatchId
                    LEFT JOIN MinorMatch AS mm WITH(NOLOCK) ON mm.MinorMatchId = m.OWPMatchId
               WHERE m.EventDateTime > @startDate
                     AND (hn.HomeName LIKE '%' + @Keyword + '%'
                          OR an.AwayName LIKE '%' + @Keyword + '%'
                          OR l.OWPLeagueName LIKE '%' + @Keyword + '%');
		
		
        SELECT DISTINCT 
               ep.OwpMatchId, 
               ep.OwpLeagueId, 
               ep.LeagueName, 
               ep.HomeId, 
               ep.AwayId, 
               ep.HomeName, 
               ep.AwayName, 
               ep.IsLeague, 
               ep.EventDateTimeGmt8
        FROM @tblEventOption AS ep
        WHERE ep.MinorBettype NOT IN(-1, -2, -88, -89, -5, -8)
        OR ep.MinorBettype IS NULL;
    END;