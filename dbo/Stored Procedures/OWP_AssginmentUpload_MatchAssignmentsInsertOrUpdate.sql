
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssginmentUpload_MatchAssignmentsInsertOrUpdate] @MatchAssignments NVARCHAR(MAX)
AS

/*
Created: 20200310@Jacob
Task : Assignment Uploading
DB: bodb_OWP

Revisions:
	20200310@Jacob: New structure of Assignment Uploading - [Redmine: #129397]
	
*/

     SET NOCOUNT ON;
     CREATE TABLE #tmpTable
     (MatchId        INT, 
      BetType        INT, 
      AssignmentType TINYINT, 
      UserId         INT, 
      AssignmentNote NVARCHAR(200)
     );
     DECLARE @idoc INT;
     EXEC sp_xml_preparedocument 
          @idoc OUTPUT, 
          @MatchAssignments;
     INSERT INTO #tmpTable
            SELECT MatchId, 
                   BetType, 
                   AssignmentType, 
                   UserId, 
                   AssignmentNote
            FROM OPENXML(@idoc, '/Root/MatchAssignment', 1) WITH(MatchId INT, BetType INT, AssignmentType TINYINT, UserId INT, AssignmentNote NVARCHAR(200));
     EXEC sp_xml_removedocument 
          @idoc;

     -- DELETE Assignment
     DELETE ma
     FROM dbo.Assignment ma
          INNER JOIN #tmpTable t ON t.MatchId = ma.OWPMatchId;

     -- INSERT Assignment
     INSERT INTO [dbo].[Assignment]
     ([OWPMatchId], 
      [Bettype], 
      [AssignmentType], 
      [UserId], 
      [AssignmentNote]
     )
            SELECT MatchId, 
                   t.BetType, 
                   AssignmentType, 
                   CASE WHEN UserId = 0 THEN NULL ELSE UserId END, 
                   AssignmentNote
            FROM #tmpTable t
                 INNER JOIN MajorBettype v WITH(NOLOCK) ON t.BetType = v.BettypeId
				 WHERE UserId > 0 OR LEN(AssignmentNote) > 0;

     -- DROP tmpTable
     DROP TABLE #tmpTable;
