
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssignmentUpload_MatchAgentsInsertOrUpdate] @MatchAgents NVARCHAR(MAX), 
                                                                       @MatchIds    VARCHAR(MAX)
AS

/*
Created: 20200310@Jacob
Task : Assignment Uploading
DB: bodb_OWP

Revisions:
	20200310@Jacob: New structure of Assignment Uploading - [Redmine: #129397]
	20231215@Mira: refactor upload flow - [Redmine: #1976174]
*/

     SET NOCOUNT ON;
     CREATE TABLE #allMatchIds(MatchId INT);
     INSERT INTO #allMatchIds
            SELECT DISTINCT 
                   val
            FROM fnc_SplitStrings(@MatchIds, ',') u OPTION(MAXRECURSION 0);
     CREATE TABLE #tmpTable
     (MatchId INT, 
      Agent   NVARCHAR(500), 
      AgentId INT
     );
     DECLARE @idoc INT;
     EXEC sp_xml_preparedocument 
          @idoc OUTPUT, 
          @MatchAgents;
     INSERT INTO #tmpTable
            SELECT DISTINCT 
                   MatchId, 
                   Agent, 
                   NULL
            FROM OPENXML(@idoc, '/Root/MatchAgent', 1) WITH(MatchId INT, Agent NVARCHAR(500));
     EXEC sp_xml_removedocument 
          @idoc;

     -- INSERT Agent
     INSERT INTO dbo.Agent
            SELECT DISTINCT 
                   t.Agent
            FROM #tmpTable t
                 LEFT JOIN dbo.Agent a WITH(NOLOCK) ON t.Agent = a.AgentName
            WHERE a.AgentName IS NULL;

     -- Update AgentId to temp table
     UPDATE t
       SET 
           t.AgentId = a.AgentId
     FROM #tmpTable T
          LEFT JOIN dbo.Agent a WITH(NOLOCK) ON t.Agent = a.AgentName;

     -- DELETE Match Agent
     DELETE ma
     FROM dbo.MatchAgent ma
          INNER JOIN #allMatchIds t ON t.MatchId = ma.OWPMatchId
          LEFT JOIN #tmpTable tt ON tt.MatchId = ma.OWPMatchId
                                    AND tt.AgentId = ma.AgentId
     WHERE tt.AgentId IS NULL;

     -- INSERT Match Agent
     INSERT INTO dbo.MatchAgent
     (OWPMatchId, 
      AgentId
     )
            SELECT DISTINCT 
                   t.MatchId, 
                   t.AgentId
            FROM #tmpTable t
            WHERE NOT EXISTS
            (
                SELECT 1
                FROM MatchAgent ma
                WHERE ma.OWPMatchId = t.MatchId
                      AND t.AgentId = ma.AgentId
            );

     -- DROP tmpTable
     DROP TABLE #tmpTable;
     DROP TABLE #allMatchIds;