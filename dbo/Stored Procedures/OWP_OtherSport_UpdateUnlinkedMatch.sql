
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OtherSport_UpdateUnlinkedMatches] @UnlinkedMatches NVARCHAR(MAX)
AS

/*    
 Created: 20220112@Tyler
 Task : sync matches from adminsite
 DB: bodb_OWP    
    
 Revisions:
	20220112@Tyler: Initial SP - [Redmine: #167315]
	
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT, @NewLogData NVARCHAR(MAX), @OldLogData NVARCHAR(MAX);
        SET @StartRun = GETDATE();
        DECLARE @idoc INT;
        CREATE TABLE #tmpTable
        (OSMatchId        INT, 
         AdminSiteMatchId INT NULL, 
         OWPMatch         NVARCHAR(MAX), 
         AdminSiteMatch   NVARCHAR(MAX)
        );
        EXEC sp_xml_preparedocument 
             @idoc OUTPUT, 
             @UnlinkedMatches;
        INSERT INTO #tmpTable
        (OSMatchId, 
         AdminSiteMatchId, 
         OWPMatch, 
         AdminSiteMatch
        )
               SELECT OSMatchId, 
                      AdminSiteMatchId, 
                      OWPMatch, 
                      AdminSiteMatch
               FROM OPENXML(@idoc, '/Root/LinkedMatch', 1) WITH([OSMatchId] INT, [AdminSiteMatchId] INT, [OWPMatch] NVARCHAR(MAX), [AdminSiteMatch] NVARCHAR(MAX));
        UPDATE m
          SET 
              m.AdminSiteMatchId = t.AdminSiteMatchId
        FROM OSMatch m
             INNER JOIN #tmpTable t ON m.OSMatchId = t.OSMatchId
        WHERE ISNULL(m.AdminSiteMatchId, 0) = 0;

        -- LOG
        DECLARE @OSMatchId INT= 0;
        WHILE(1 = 1)
            BEGIN
                DECLARE @OWPMatch NVARCHAR(MAX);
                DECLARE @AdminSiteMatch NVARCHAR(MAX);
                SELECT TOP 1 @OWPMatch = OWPMatch, 
                             @AdminSiteMatch = AdminSiteMatch, 
                             @OSMatchId = OSMatchId
                FROM #tmpTable
                WHERE OSMatchId > @OSMatchId
                ORDER BY OSMatchId;
                IF @@ROWCOUNT = 0
                    BREAK;
                DECLARE @oldData XML;
                DECLARE @newData XML;
                SET @oldData =
                (
                    SELECT @OWPMatch AS '@om' FOR XML PATH('z'), ROOT('r')
                );
                SET @newData =
                (
                    SELECT @AdminSiteMatch AS '@am' FOR XML PATH('z'), ROOT('r')
                );
                SET @OldLogData = REPLACE(CONVERT(NVARCHAR(MAX), @oldData), '" />', '"/"');
                SET @NewLogData = REPLACE(CONVERT(NVARCHAR(MAX), @oldData), '" />', '"/"');
                SET @EndRun = GETDATE();
                SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
                EXEC dbo.OWP_WriteLog 
                     @CreatorId = 0, 
                     @SPName = 'OWP_OtherSport_UpdateUnlinkedMatches', 
                     @LoggedDate = @StartRun, 
                     @Duration = @Duration, 
                     @ObjectId = @OSMatchId, 
                     @Data = @NewLogData, 
                     @DataOld = @OldLogData;
            END;
        DROP TABLE #tmpTable;
        EXEC sp_xml_removedocument 
             @idoc;
    END;