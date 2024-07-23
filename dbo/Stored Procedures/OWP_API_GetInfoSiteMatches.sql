
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_API_GetInfoSiteMatches] @Ids NVARCHAR(MAX)
AS

/*    
Created: 20231225@Johnny
Task : Get InfoSiteMatch
DB: bodb_OWP    
    
Revisions:     
  20231225@Johnny: initial SP - [Redmine: #198102] 
  20240708@Johnny: refactor - [Redmine: #201604]  
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tempMatch TABLE(InfoSiteMatchId INT);
        INSERT INTO @tempMatch
               SELECT DISTINCT 
                      value
               FROM STRING_SPLIT(@Ids, ',');
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
             INNER JOIN @tempMatch AS t ON m.InfoSiteMatchId = t.InfoSiteMatchId
             LEFT JOIN dbo.EventPickingConfirmed AS ec WITH(NOLOCK) ON m.InfoSiteMatchId = ec.InfositeId;
    END;