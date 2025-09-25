
/*<info serverAlias="DBOWP-bodb02" executers="wsv_nap" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TaskList_GetCompletedMatchFromMainDB] @MatchInfoJson VARCHAR(MAX)
AS

/*
Created: 20230526@Mira
Task : Refactor task list
DB: bodb02

Revisions:
	20230526@Mira: Refactor task list - [Redmine: #188624]
	20240930@Los: Hide completed main match by check all child match completed - [Redmine: #210700]
    20250925@Frankie: Hide Completed Matches for SABA game - PENALTY SHOOTOUTS - [Redmine: #236985]
*/

    BEGIN
        SET NOCOUNT ON;
        -- AdminSiteIds

        DECLARE @tblMatchInfo TABLE
        (matchId INT, 
         league  NVARCHAR(2000)
        );
        INSERT INTO @tblMatchInfo
        (matchId, 
         league
        )
               SELECT *
                FROM OPENJSON(@MatchInfoJson) WITH(matchId INT, league VARCHAR(2000));

        -- select completed match

        SELECT m.matchid
        FROM dbo.match m WITH(NOLOCK)
             INNER JOIN @tblMatchInfo AS a ON m.matchid = a.MatchId
        WHERE m.eventstatus = 'Completed'
        UNION
		
		SELECT m.ParentID
                            
        FROM [match] AS m WITH(NOLOCK)
             INNER JOIN @tblMatchInfo AS a ON m.ParentID = a.matchId
			 INNER JOIN match_remark AS mr WITH(NOLOCK) ON mr.matchid=m.matchid
        WHERE a.league like '%SABA%' 
            AND a.league like '%PENALTY SHOOTOUTS%'
		GROUP BY m.ParentID
        HAVING COUNT(*) = SUM(CASE
                                  WHEN mr.confirmFT = 0
                                  THEN 0
                                  ELSE 1
                              END);
							  
     
    END;