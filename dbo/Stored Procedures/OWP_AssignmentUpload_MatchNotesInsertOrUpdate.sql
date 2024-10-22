
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssignmentUpload_MatchNotesInsertOrUpdate] @MatchNotes NVARCHAR(MAX), 
                                                                      @UserId     INT, 
                                                                      @MatchIds   VARCHAR(MAX)
AS

/*
Created: 20200310@Jacob
Task : Assignment Uploading
DB: bodb_OWP

Revisions:
	20200310@Jacob: New structure of Assignment Uploading - [Redmine: #129397]
	
*/

     SET NOCOUNT ON;
     DECLARE @allMatchIds TABLE(MatchId INT);
     INSERT INTO @allMatchIds
            SELECT DISTINCT 
                   val
            FROM fnc_SplitStrings(@MatchIds, ',') u OPTION(MAXRECURSION 0);
     CREATE TABLE #tmpTable
     (MatchId INT, 
      Note    NVARCHAR(500)
     );
     DECLARE @idoc INT;
     EXEC sp_xml_preparedocument 
          @idoc OUTPUT, 
          @MatchNotes;
     INSERT INTO #tmpTable
            SELECT DISTINCT 
                   MatchId, 
                   [Note]
            FROM OPENXML(@idoc, '/Root/MatchNote', 1) WITH(MatchId INT, Note NVARCHAR(500));
     EXEC sp_xml_removedocument 
          @idoc;

     -- DELETE Match Note
     DELETE m
     FROM dbo.MatchNote m
          INNER JOIN @allMatchIds t ON t.MatchId = m.OWPMatchId;

     -- INSERT Match Note
     INSERT INTO dbo.MatchNote
     (OWPMatchId, 
      CreatedDate, 
      CreatedBy, 
      [Note]
     )
            SELECT DISTINCT 
                   MatchId, 
                   GETDATE(), 
                   @UserId, 
                   [Note]
            FROM #tmpTable t;

     -- DROP tmpTable
     DROP TABLE #tmpTable;