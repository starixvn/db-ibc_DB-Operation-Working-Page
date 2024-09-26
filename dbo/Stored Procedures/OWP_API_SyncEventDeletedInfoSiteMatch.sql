
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_API_SyncEventDeletedInfoSiteMatch] @Ids NVARCHAR(MAX)

/*      
 Created: 20190104@Kane.Le  
 Task : Service Prevent sync deleted event   
 DB: bodb_OWP      
      
Revisions:  
	20190104@Kane.Le: Initial SP - [Redmine: #107257]  
	20200913@Jacob: Remove keyword IN - [Redmine: #134336]
	20210914@Tyler: Insert Service Log - [Redmine: #161379]
*/

AS
     DECLARE @EventDate DATETIME= GETDATE();
     DECLARE @tempMatch TABLE(MatchId INT);
     DECLARE @tmpLog TABLE
     (DataOld      NVARCHAR(MAX), 
      DataNew      NVARCHAR(MAX), 
      UpdatedField NCHAR(100), 
      TableName    NCHAR(100), 
      OWPMatchId   INT
     );
     INSERT INTO @tempMatch
            SELECT DISTINCT 
                   val
            FROM fnc_SplitStrings(@Ids, ',') u OPTION(MAXRECURSION 0);
     INSERT INTO @tmpLog
     ([DataOld], 
      [DataNew], 
      [UpdatedField], 
      [TableName], 
      [OWPMatchId]
     )
            SELECT m.IsDeleted, 
                   1, 
                   'IsDeleted', 
                   'InfoSiteMatch', 
                   NULL
            FROM dbo.InfoSiteMatch m WITH(ROWLOCK)
                 INNER JOIN @tempMatch t ON m.InfoSiteMatchId = t.MatchId;
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
     INSERT INTO @tmpLog
     ([DataOld], 
      [DataNew], 
      [UpdatedField], 
      [TableName], 
      [OWPMatchId]
     )
            SELECT m.InfoSiteMatchId, 
                   NULL, 
                   'InfoSiteMatchId', 
                   'OWPMatch', 
                   m.OWPMatchId
            FROM dbo.OWPMatch m WITH(ROWLOCK)
                 INNER JOIN @tempMatch t ON m.InfoSiteMatchId = t.MatchId;
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

     -- Insert Service Log
     INSERT INTO dbo.ServiceActionLog
     ([ActionBy], 
      [LogDate], 
      [DataOld], 
      [DataNew], 
      [UpdatedField], 
      [TableName], 
      [OWPMatchId], 
      [SPName]
     )
            SELECT 'SyncDeletedInfoSiteMatch', 
                   @EventDate, 
                   DataOld, 
                   DataNew, 
                   UpdatedField, 
                   TableName, 
                   OWPMatchId, 
                   'OWP_API_SyncEventDeletedInfoSiteMatch'
            FROM @tmpLog t;
GO