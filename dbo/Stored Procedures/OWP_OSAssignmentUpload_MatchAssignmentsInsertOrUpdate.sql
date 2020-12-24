
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OSAssignmentUpload_MatchAssignmentsInsertOrUpdate] @MatchAssignments NVARCHAR(MAX), 
                                                                              @MatchIds         VARCHAR(MAX)
AS

/*
Created: 20201224@Esther
Task : Event Upload for Othersports
DB: bodb_OWP

Revisions:
	20201224@Esther: New structure of Event Upload for Othersports - [Redmine: #146962]
	
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @allMatchIds TABLE(MatchId INT);
        INSERT INTO @allMatchIds
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@MatchIds, ',') u OPTION(MAXRECURSION 0);
        CREATE TABLE #tmpTable
        (OSMatchId      INT, 
         BetTypeName    NVARCHAR(200), 
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
                      OSMatchId, 
                      BetTypeName, 
                      AssignmentType, 
                      UserId, 
                      NULLIF(AssignmentNote, '')
               FROM OPENXML(@idoc, '/Root/MatchAssignment', 1) WITH(OSMatchId INT, BetTypeName NVARCHAR(200), AssignmentType TINYINT, UserId INT, AssignmentNote NVARCHAR(200));
        EXEC sp_xml_removedocument 
             @idoc;

        -- DELETE Assignment
        DELETE osa
        FROM dbo.OSAssignment osa
             INNER JOIN @allMatchIds t ON t.MatchId = osa.OSMatchId;

        -- INSERT Assignment
        INSERT INTO [dbo].[OSAssignment]
        ([OSMatchId], 
         [BettypeName], 
         [AssignmentType], 
         [UserId], 
         [AssignmentNote]
        )
               SELECT DISTINCT 
                      OSMatchId, 
                      BetTypeName, 
                      AssignmentType, 
                      NULLIF(UserId, 0), 
                      AssignmentNote
               FROM #tmpTable t;   
        -- DROP tmpTable
        DROP TABLE #tmpTable;
    END;