
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssignmentUpload_MatchOtherProvidersInsertOrUpdate] @MatchProviders NVARCHAR(MAX), 
                                                                               @MatchIds       VARCHAR(MAX)
AS

/*
Created: 20200310@Jacob
Task : Assignment Uploading
DB: bodb_OWP

Revisions:
	20200310@Jacob: New structure of Assignment Uploading - [Redmine: #129397]
	20200715@Jacob: Bug Provider name in NVARCHAR  - [Redmine: #137418]
*/

     SET NOCOUNT ON;
     DECLARE @allMatchIds TABLE(MatchId INT);
     INSERT INTO @allMatchIds
            SELECT DISTINCT 
                   val
            FROM fnc_SplitStrings(@MatchIds, ',') u OPTION(MAXRECURSION 0);
     CREATE TABLE #tmpTable
     (MatchId    INT, 
      [Provider] VARCHAR(500)
     );
     DECLARE @idoc INT;
     EXEC sp_xml_preparedocument 
          @idoc OUTPUT, 
          @MatchProviders;
     INSERT INTO #tmpTable
            SELECT DISTINCT 
                   MatchId, 
                   [Provider]
            FROM OPENXML(@idoc, '/Root/MatchProvider', 1) WITH(MatchId INT, [Provider] VARCHAR(500));
     EXEC sp_xml_removedocument 
          @idoc;

     -- INSERT [OtherProvider]
     INSERT INTO dbo.[OtherProvider]([OtherProviderName])
            SELECT DISTINCT 
                   t.[Provider]
            FROM #tmpTable t
                 LEFT JOIN dbo.[OtherProvider] a WITH(NOLOCK) ON t.[Provider] = a.OtherProviderName
            WHERE a.OtherProviderName IS NULL;

     -- DELETE MatchOtherProvider
     DELETE ma
     FROM dbo.MatchOtherProvider ma
          INNER JOIN @allMatchIds t ON t.MatchId = ma.OWPMatchId;

     -- INSERT MatchOtherProvider
     INSERT INTO dbo.MatchOtherProvider
     (OWPMatchId, 
      OtherProviderId
     )
            SELECT DISTINCT 
                   t.MatchId, 
                   a.OtherProviderId
            FROM #tmpTable t
                 INNER JOIN dbo.[OtherProvider] a WITH(NOLOCK) ON t.[Provider] = a.OtherProviderName;

     -- DROP tmpTable
     DROP TABLE #tmpTable;