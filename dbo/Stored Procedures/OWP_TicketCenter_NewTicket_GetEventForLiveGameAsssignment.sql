
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_NewTicket_GetEventForLiveGameAsssignment] @Keyword NVARCHAR(500)
AS

/*      
 Created: 20220216@Johnny
 Task : Get event option
 DB: bodb_OWP      
      
 Revisions:          
	20220929@Johnny: Init sp - [Redmine: #178183]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @date DATETIME;
        DECLARE @startDate DATETIME;
        SELECT @date = CAST(CAST(GETDATE() AS DATE) AS DATETIME);
        SELECT @startDate = DATEADD(DAY, -30, CONVERT(DATETIME, @date));
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
         UserName          NVARCHAR(255), 
         NickName          NVARCHAR(255), 
         RecipientId       INT, 
         IsLeague          BIT, 
         HasAssignee       BIT,
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
         UserName, 
         NickName, 
         RecipientId, 
         EventDateTimeGmt8, 
         HasAssignee,
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
                      u.Username, 
                      u.Nickname, 
                      a.UserId AS RecipientId, 
                      m.EventDateTime,
                      CASE
                          WHEN a.UserId IS NULL
                          THEN 0
                          ELSE 1
                      END,
					  mm.MinorBettypeId
               FROM OWPMatch AS m WITH(NOLOCK)
                    INNER JOIN OWPLeague AS l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
                    INNER JOIN @tblOWPMatchHomeName AS hn ON hn.OWPMatchId = m.OWPMatchId
                    INNER JOIN @tblOWPMatchAwayName AS an ON an.OWPMatchId = m.OWPMatchId
                    LEFT JOIN MinorMatch AS mm WITH(NOLOCK) ON mm.MinorMatchId = m.OWPMatchId 
                    LEFT JOIN Assignment AS a WITH(NOLOCK) ON m.OWPMatchId = a.OWPMatchId
                    LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
               WHERE m.EventDateTime > @startDate
                     AND (hn.HomeName LIKE '%' + @Keyword + '%'
                          OR an.AwayName LIKE '%' + @Keyword + '%'
                          OR l.OWPLeagueName LIKE '%' + @Keyword + '%') 
        SELECT DISTINCT 
               ep.OwpMatchId, 
               ep.OwpLeagueId, 
               ep.LeagueName, 
               ep.HomeId, 
               ep.AwayId, 
               ep.HomeName, 
               ep.AwayName, 
               ep.IsLeague, 
               ep.RecipientId, 
               ep.UserName, 
               ep.NickName, 
               ep.EventDateTimeGmt8, 
               ep.HasAssignee
        FROM @tblEventOption AS ep
		WHERE ep.MinorBettype NOT IN(-1, -2, -88, -89, -5, -6) or ep.MinorBettype is null;
    END;