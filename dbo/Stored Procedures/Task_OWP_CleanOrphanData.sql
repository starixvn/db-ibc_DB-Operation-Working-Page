
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[Task_OWP_CleanOrphanData]
AS

/*
	Created: Jacob
	Date: 2020-02-28
	Task: Clean Old Data
	DB: DBOWP/bodb_OWP
Revisions:
- 20200228@Jacob: Clean Old Data - [Redmine: #129435]
Remarks:
- Delete orphan data of tables: OWPTeam, OWPLeague, AssignmentUploadingOtherTrader
- Only run this sp at UM time
*/

     SET NOCOUNT ON;
     DECLARE @RemainFlag BIT; 
     -- DELETE Orphan Team
     SELECT @RemainFlag = 1;
     WHILE @RemainFlag = 1
         BEGIN
             DELETE TOP (3000)
             OWPTeam WITH(ROWLOCK)
             WHERE OWPTeamId NOT IN
             (
                 SELECT OWPHomeId
                 FROM OWPMatch WITH(NOLOCK)
                 UNION
                 SELECT OWPAwayId
                 FROM OWPMatch WITH(NOLOCK)
             );

             IF @@ROWCOUNT = 0
                 SELECT @RemainFlag = 0;
             ELSE
				PRINT '3000 orphan rows of OWPTeam was deleted. Now is ' + CONVERT(VARCHAR(50), GETDATE());
         END;
     -- DELETE Orphan League
     SELECT @RemainFlag = 1;
     WHILE @RemainFlag = 1
         BEGIN
             DELETE TOP (3000)
             OWPLeague WITH(ROWLOCK)
             WHERE OWPLeagueId NOT IN
             (
                 SELECT OWPLeagueId
                 FROM OWPMatch WITH(NOLOCK)
             );

             
             IF @@ROWCOUNT = 0
				SELECT @RemainFlag = 0;
             ELSE
				PRINT '3000 orphan rows of OWPLeague was deleted. Now is ' + CONVERT(VARCHAR(50), GETDATE());
         END;

     -- DELETE Orphan AssignmentUploadingOtherTrader
     SELECT @RemainFlag = 1;
     WHILE @RemainFlag = 1
         BEGIN
             DELETE TOP (3000)
             AssignmentUploadingOtherTrader WITH(ROWLOCK)
             WHERE SessionId NOT IN
             (
                 SELECT sessionid
                 FROM AssignmentUploading WITH(NOLOCK)
             );

             
             IF @@ROWCOUNT = 0
				SELECT @RemainFlag = 0;
			 ELSE
				PRINT '3000 orphan rows of AssignmentUploadingOtherTrader was deleted. Now is ' + CONVERT(VARCHAR(50), GETDATE());
         END;