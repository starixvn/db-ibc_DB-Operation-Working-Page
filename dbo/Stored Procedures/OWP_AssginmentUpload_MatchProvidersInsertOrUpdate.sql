
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssginmentUpload_MatchProvidersInsertOrUpdate] @MatchProviders NVARCHAR(MAX)
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
     (MatchId    INT, 
      [Provider] NVARCHAR(500)
     );
     DECLARE @idoc INT;
     EXEC sp_xml_preparedocument 
          @idoc OUTPUT, 
          @MatchProviders;
     INSERT INTO #tmpTable
            SELECT DISTINCT 
                   MatchId, 
                   [Provider]
            FROM OPENXML(@idoc, '/Root/MatchProvider', 1) WITH(MatchId INT, [Provider] NVARCHAR(500));
     EXEC sp_xml_removedocument 
          @idoc;

     -- INSERT [Provider]
     INSERT INTO dbo.[Provider]([ProviderName])
            SELECT DISTINCT 
                   t.[Provider]
            FROM #tmpTable t
                 LEFT JOIN dbo.[Provider] a WITH(NOLOCK) ON t.[Provider] = a.ProviderName
            WHERE a.ProviderName IS NULL;

     -- DELETE MatchProvider
     DELETE ma
     FROM dbo.MatchProvider ma
          INNER JOIN #tmpTable t ON t.MatchId = ma.OWPMatchId;

     -- INSERT MatchProvider
     INSERT INTO dbo.MatchProvider
     (OWPMatchId, 
      ProviderId
     )
            SELECT DISTINCT 
                   t.MatchId, 
                   a.ProviderId
            FROM #tmpTable t
                 INNER JOIN dbo.[Provider] a WITH(NOLOCK) ON t.[Provider] = a.ProviderName;
     -- DROP tmpTable
     DROP TABLE #tmpTable;