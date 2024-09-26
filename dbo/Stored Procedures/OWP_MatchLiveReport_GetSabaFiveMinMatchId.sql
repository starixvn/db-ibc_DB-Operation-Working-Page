
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_MatchLiveReport_GetSabaFiveMinMatchId] @Id VARCHAR(MAX)
AS

/*
Created: 20220516@Johnny.Thai
Task : get OWPMatchId saba 5min
DB: bodb_OWP	

Revisions:
	20220516@Johnny.Thai: Initial SP - [Redmine: #172695]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tempMatchId TABLE(OWPMatchId INT);
        INSERT INTO @tempMatchId(OWPMatchId)
               SELECT DISTINCT 
                      value
               FROM STRING_SPLIT(@Id, ',');
        DECLARE @tempOWPMatch TABLE
        (OWPMatchId    INT, 
         OWPLeagueId   INT, 
         OWPHomeId     INT, 
         OWPAwayId     INT, 
         EventDate     DATETIME, 
         EventDateTime DATETIME
        );
        INSERT INTO @tempOWPMatch
        (OWPMatchId, 
         OWPLeagueId, 
         OWPHomeId, 
         OWPAwayId, 
         EventDate, 
         EventDateTime
        )
               SELECT m.OWPMatchId, 
                      m.OWPLeagueId, 
                      m.OWPHomeId, 
                      m.OWPAwayId, 
                      m.EventDate, 
                      m.EventDateTime
               FROM OWPMatch AS m
                    INNER JOIN @tempMatchId AS temp ON m.OWPMatchId = temp.OWPMatchId;
        SELECT MIN(tm.OWPMatchId) AS OWPMatchId
        FROM @tempOWPMatch AS tm
        GROUP BY tm.OWPLeagueId, 
                 tm.OWPHomeId, 
                 tm.OWPAwayId, 
                 tm.EventDate, 
                 DATEPART(HOUR, tm.EventDateTime);
    END;