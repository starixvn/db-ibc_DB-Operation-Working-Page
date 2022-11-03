
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE dbo.[OWP_API_PushInfoSiteChildMatches] @ChildMatchesJson NVARCHAR(MAX)

/*
Created: 20221027@Mira
Task : Event Picking New
DB: bodb_OWP	

Revisions:
	20201020@Mira: Save child matches from Infosite - Redmine: #179302
*/

AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @Temp TABLE
        (ParentInfoSiteMatchId INT, 
         AdminSiteMatchId      INT, 
         MinorBettypeId        INT, 
         SubType               INT, 
         LeagueName            NVARCHAR(500), 
         HomeName              NVARCHAR(200), 
         AwayName              NVARCHAR(200), 
         OWPLeagueId           INT NULL, 
         OWPHomeId             INT NULL, 
         OWPAwayId             INT NULL, 
         EventDateTime         DATETIME, 
         UpdatedTime           DATETIME
        );
        INSERT INTO @Temp
        (ParentInfoSiteMatchId, 
         AdminSiteMatchId, 
         MinorBettypeId, 
         SubType, 
         LeagueName, 
         HomeName, 
         AwayName, 
         EventDateTime, 
         UpdatedTime
        )
               SELECT *
               FROM OPENJSON(@ChildMatchesJson) WITH(ParentInfoSiteMatchId INT, AdminSiteMatchId INT, MinorBettypeId INT, SubType INT, LeagueName NVARCHAR(500), HomeName NVARCHAR(200), AwayName NVARCHAR(200), EventDateTime DATETIME, UpdatedTime DATETIME);

        -- insert new league
        INSERT INTO dbo.OWPLeague(OWPLeagueName)
               SELECT DISTINCT 
                      t.LeagueName
               FROM @Temp AS t
               WHERE NOT EXISTS
               (
                   SELECT 1
                   FROM dbo.OWPLeague AS l WITH(NOLOCK)
                   WHERE t.LeagueName = l.OWPLeagueName
               );

        -- update OWPLeagueId
        UPDATE t
          SET 
              t.OWPLeagueId = l.OWPLeagueId
        FROM @Temp AS t
             INNER JOIN dbo.OWPLeague AS l WITH(NOLOCK) ON t.LeagueName = l.OWPLeagueName;

        -- insert new team
        INSERT INTO dbo.OWPTeam(OWPTeamName)
               SELECT temp.TeamName
               FROM
               (
                   SELECT t.HomeName AS TeamName
                   FROM @Temp AS t
                   UNION
                   SELECT t.AwayName AS TeamName
                   FROM @Temp AS t
               ) AS temp
               WHERE NOT EXISTS
               (
                   SELECT 1
                   FROM dbo.OWPTeam AS t WITH(NOLOCK)
                   WHERE temp.TeamName = t.OWPTeamName
               );

        -- update OWPHomeId
        UPDATE t
          SET 
              t.OWPHomeId = team.OWPTeamId
        FROM @Temp AS t
             INNER JOIN dbo.OWPTeam AS team WITH(NOLOCK) ON t.HomeName = team.OWPTeamName;

        -- update OWPAwayId
        UPDATE t
          SET 
              t.OWPAwayId = team.OWPTeamId
        FROM @Temp AS t
             INNER JOIN dbo.OWPTeam AS team WITH(NOLOCK) ON t.AwayName = team.OWPTeamName;

        -- Insert into table InfoSiteChildMatch
        INSERT INTO dbo.InfoSiteChildMatch
        (ParentInfoSiteMatchId, 
         AdminSiteMatchId, 
         MinorBettypeId, 
         SubType, 
         OWPLeagueId, 
         OWPHomeId, 
         OWPAwayId, 
         EventDateTime, 
         UpdatedTime
        )
               SELECT [ParentInfoSiteMatchId], 
                      [AdminSiteMatchId], 
                      [MinorBettypeId], 
                      [SubType], 
                      [OWPLeagueId], 
                      [OWPHomeId], 
                      [OWPAwayId], 
                      [EventDateTime], 
                      [UpdatedTime]
               FROM @Temp t
               WHERE NOT EXISTS
               (
                   SELECT 1
                   FROM dbo.InfoSiteChildMatch
                   WHERE AdminSiteMatchId = t.AdminSiteMatchId
               );

        -- Update table InfoSiteChildMatch
        UPDATE dbo.InfoSiteChildMatch
          SET 
              AdminSiteMatchId = t.AdminSiteMatchId, 
              MinorBettypeId = t.MinorBettypeId, 
              SubType = t.SubType, 
              EventDateTime = t.EventDateTime, 
              OWPLeagueId = t.OWPLeagueId, 
              OWPHomeId = t.OWPHomeId, 
              OWPAwayId = t.OWPAwayId, 
              UpdatedTime = t.UpdatedTime
        FROM @Temp t
        WHERE EXISTS
        (
            SELECT 1
            FROM dbo.InfoSiteChildMatch
            WHERE AdminSiteMatchId = t.AdminSiteMatchId
                  AND UpdatedTime <> t.UpdatedTime
        );
    END;