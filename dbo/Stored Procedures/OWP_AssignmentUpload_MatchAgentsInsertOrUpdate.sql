
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssignmentUpload_MatchAgentsInsertOrUpdate] @MatchAgents NVARCHAR(MAX), 
                                                                       @MatchIds    VARCHAR(MAX)
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
      Agent   NVARCHAR(500)
     );
     DECLARE @idoc INT;
     EXEC sp_xml_preparedocument 
          @idoc OUTPUT, 
          @MatchAgents;
     INSERT INTO #tmpTable
            SELECT DISTINCT 
                   MatchId, 
                   Agent
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

     -- DELETE Match Agent
     DELETE ma
     FROM dbo.MatchAgent ma
          INNER JOIN @allMatchIds t ON t.MatchId = ma.OWPMatchId;

     -- INSERT Match Agent
     INSERT INTO dbo.MatchAgent
     (OWPMatchId, 
      AgentId
     )
            SELECT DISTINCT 
                   t.MatchId, 
                   a.AgentId
            FROM #tmpTable t
                 INNER JOIN dbo.Agent a WITH(NOLOCK) ON t.Agent = a.AgentName;
     -- DROP tmpTable
     DROP TABLE #tmpTable;