
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

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
        DECLARE @tempMatchId TABLE(Id INT);
        INSERT INTO @tempMatchId(Id)
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@Id, ',') u OPTION(MAXRECURSION 0);
        DECLARE @tempOWPMatch TABLE
        (OWPMatchId INT, 
         CountMatch INT
        );
        INSERT INTO @tempOWPMatch
        (OWPMatchId, 
         CountMatch
        )
               SELECT COUNT(m.OWPHomeId) AS CountMatch, 
                      MIN(m.OWPMatchId) AS OWPMatchId
               FROM OWPMatch AS m
                    INNER JOIN @tempOWPMatch AS temp ON m.OWPMatchId = temp.OWPMatchId
               GROUP BY m.OWPLeagueId, 
                        m.OWPHomeId, 
                        m.OWPAwayId, 
                        m.EventDate, 
                        DATEPART(HOUR, m.EventDateTime);
        SELECT m.OWPMatchId
        FROM @tempOWPMatch AS m
        WHERE m.CountMatch = 4;
    END;