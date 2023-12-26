
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_API_GetTeamRoundInfosByDate] @EventDate DATETIME
AS

/*    
Created: 20231225@Liam
Task : Get round info
DB: bodb_OWP    
    
Revisions:     
  20231225@Liam: Get round info - [Redmine: #198102]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00'), @ToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '11:59:59');
        -- select from infosite match
        SELECT DISTINCT 
               m.InfoSiteMatchId, 
               m.TeamRound,
               CASE
                   WHEN ec.InfositeId IS NULL
                   THEN 0
                   ELSE 1
               END AS IsCheck
        FROM dbo.[InfoSiteMatch] AS m WITH(NOLOCK)
             LEFT JOIN dbo.EventPickingConfirmed AS ec WITH(NOLOCK) ON m.InfoSiteMatchId = ec.InfositeId
        WHERE m.EventDateTime >= @FromDateTime
              AND m.EventDateTime <= @ToDateTime
              AND m.IsDeleted = 0;
    END;