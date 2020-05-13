
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssginmentUpload_MatchTelevisionsInsertOrUpdate] @MatchTVs NVARCHAR(MAX)
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
     (MatchId INT, 
      [TV]    NVARCHAR(500)
     );
     DECLARE @idoc INT;
     EXEC sp_xml_preparedocument 
          @idoc OUTPUT, 
          @MatchTVs;
     INSERT INTO #tmpTable
            SELECT MatchId, 
                   [TV]
            FROM OPENXML(@idoc, '/Root/MatchTelevision', 1) WITH(MatchId INT, [TV] NVARCHAR(500));
     EXEC sp_xml_removedocument 
          @idoc;

     -- INSERT Television
     INSERT INTO dbo.[Television](TVCode)
            SELECT t.[TV]
            FROM #tmpTable t
                 LEFT JOIN dbo.[Television] a WITH(NOLOCK) ON t.TV = a.TVCode
            WHERE a.TVCode IS NULL;

     -- DELETE MatchTelevision
     DELETE ma
     FROM dbo.MatchTelevision ma
          INNER JOIN #tmpTable t ON t.MatchId = ma.OWPMatchId;

     -- INSERT MatchTelevision
     INSERT INTO dbo.MatchTelevision
     (OWPMatchId, 
      TVId
     )
            SELECT t.MatchId, 
                   a.TVId
            FROM #tmpTable t
                 INNER JOIN dbo.[Television] a WITH(NOLOCK) ON t.TV = a.TVCode;
     -- DROP tmpTable
     DROP TABLE #tmpTable;