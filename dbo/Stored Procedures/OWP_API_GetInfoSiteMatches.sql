
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_API_GetInfoSiteMatches]
AS

/*    
Created: 20231225@Johnny
Task : Get InfoSiteMatch
DB: bodb_OWP    
    
Revisions:     
  20231225@Johnny: initial SP - [Redmine: #198102] 
*/

    BEGIN
        SET NOCOUNT ON;
        -- select from infosite match
        SELECT DISTINCT 
               m.InfoSiteMatchId, 
               m.LeagueName, 
               m.HomeName, 
               m.AwayName, 
               m.EventDateTime,
               CASE
                   WHEN ec.InfositeId IS NULL
                   THEN 0
                   ELSE 1
               END AS IsCheck
        FROM dbo.[InfoSiteMatch] AS m WITH(NOLOCK)
             LEFT JOIN dbo.EventPickingConfirmed AS ec WITH(NOLOCK) ON m.InfoSiteMatchId = ec.InfositeId
    END;