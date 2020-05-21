
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssginmentUpload_MatchAssignmentsInsertOrUpdate] @MatchAssignments NVARCHAR(MAX), 
                                                                            @IsUploadFMAndAIO BIT
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
            SELECT DISTINCT 
                   MatchId, 
                   BetType, 
                   AssignmentType, 
                   UserId,
                   NULLIF(AssignmentNote,'')                       
            FROM OPENXML(@idoc, '/Root/MatchAssignment', 1) WITH(MatchId INT, BetType INT, AssignmentType TINYINT, UserId INT, AssignmentNote NVARCHAR(200));
     EXEC sp_xml_removedocument 
          @idoc;

     -- DELETE Main Assignment
     DELETE ma
     FROM dbo.Assignment ma
          INNER JOIN #tmpTable t ON t.MatchId = ma.OWPMatchId
          LEFT JOIN dbo.MinorMatch mm ON mm.MinorMatchId = t.MatchId
     WHERE mm.ParentMatchId IS NULL;

     -- DELETE Minor Assignment	 
     DELETE ma
     FROM dbo.Assignment ma
          INNER JOIN #tmpTable t ON t.MatchId = ma.OWPMatchId
          INNER JOIN dbo.MinorMatch mm ON mm.MinorMatchId = t.MatchId
     WHERE @IsUploadFMAndAIO = 1
           OR (mm.MinorBettypeId NOT IN(-88, -89));

     -- INSERT Main Assignment
     INSERT INTO [dbo].[Assignment]
     ([OWPMatchId], 
      [Bettype], 
      [AssignmentType], 
      [UserId], 
      [AssignmentNote]
     )
            SELECT DISTINCT 
                   MatchId, 
                   t.BetType, 
                   AssignmentType,
				   NULLIF(UserId, 0),
                   AssignmentNote
            FROM #tmpTable t
                 INNER JOIN MajorBettype v WITH(NOLOCK) ON t.BetType = v.BettypeId
                 LEFT JOIN dbo.MinorMatch mm ON mm.MinorMatchId = t.MatchId
            WHERE mm.ParentMatchId IS NULL;

     -- INSERT MINOR Assignment
     INSERT INTO [dbo].[Assignment]
     ([OWPMatchId], 
      [Bettype], 
      [AssignmentType], 
      [UserId], 
      [AssignmentNote]
     )
            SELECT DISTINCT 
                   MatchId, 
                   t.BetType, 
                   AssignmentType,
				   NULLIF(UserId, 0),
                   AssignmentNote
            FROM #tmpTable t
                 INNER JOIN MajorBettype v WITH(NOLOCK) ON t.BetType = v.BettypeId
                 INNER JOIN dbo.MinorMatch mm ON mm.MinorMatchId = t.MatchId
            WHERE @IsUploadFMAndAIO = 1
                  OR (mm.MinorBettypeId NOT IN(-88, -89));
     -- DROP tmpTable
     DROP TABLE #tmpTable;