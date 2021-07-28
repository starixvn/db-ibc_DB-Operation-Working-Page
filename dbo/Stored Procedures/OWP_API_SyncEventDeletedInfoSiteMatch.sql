
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_API_SyncEventDeletedInfoSiteMatch] @Ids NVARCHAR(MAX)

/*      
 Created: 20190104@Kane.Le  
 Task : Service Prevent sync deleted event   
 DB: bodb_OWP      
      
Revisions:  
20190104@Kane.Le: Initial SP - [Redmine: #107257]  
20200913@Jacob: Remove keyword IN - [Redmine: #134336]
*/

AS
     DECLARE @tempMatch TABLE(MatchId INT);
     INSERT INTO @tempMatch
            SELECT DISTINCT 
                   val
            FROM fnc_SplitStrings(@Ids, ',') u OPTION(MAXRECURSION 0);
     UPDATE m
       SET 
           m.IsDeleted = 1
     FROM dbo.InfoSiteMatch m
     WHERE EXISTS
     (
         SELECT 1
         FROM @tempMatch t
         WHERE m.InfoSiteMatchId = t.MatchId
     );

	 UPDATE m
       SET 
           m.InfoSiteMatchId = NULL
     FROM dbo.OWPMatch m
     WHERE EXISTS
     (
         SELECT 1
         FROM @tempMatch t
         WHERE m.InfoSiteMatchId = t.MatchId
     );