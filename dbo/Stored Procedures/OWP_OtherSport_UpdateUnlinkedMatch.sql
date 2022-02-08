
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
        (OSMatchId           INT, 
         AdminSiteMatchId    INT NULL, 
         AdminSiteAway       NVARCHAR(500), 
         AdminSiteHome       NVARCHAR(500), 
         AdminSiteLeague     NVARCHAR(500), 
         OWPAway             NVARCHAR(500), 
         OWPHome             NVARCHAR(500), 
         OWPLeague           NVARCHAR(500), 
         OldAdminSiteMatchId INT NULL, 
         OldEventDate        DATETIME, 
         NewEventDate        DATETIME
        );
        EXEC sp_xml_preparedocument 
             @idoc OUTPUT, 
             @UnlinkedMatches;
        INSERT INTO #tmpTable
        (OSMatchId, 
         AdminSiteMatchId, 
         AdminSiteAway, 
         AdminSiteHome, 
         AdminSiteLeague, 
         OWPAway, 
         OWPHome, 
         OWPLeague, 
         OldAdminSiteMatchId, 
         OldEventDate, 
         NewEventDate
        )
               SELECT OSMatchId, 
                      AdminSiteMatchId, 
                      AdminSiteAway, 
                      AdminSiteHome, 
                      AdminSiteLeague, 
                      OWPAway, 
                      OWPHome, 
                      OWPLeague, 
                      OldAdminSiteMatchId, 
                      OldEventDate, 
                      NewEventDate
               FROM OPENXML(@idoc, '/Root/LinkedMatch', 1) WITH([OSMatchId] INT, [AdminSiteMatchId] INT, [AdminSiteAway] NVARCHAR(500), [AdminSiteHome] NVARCHAR(500), [AdminSiteLeague] NVARCHAR(500), [OWPAway] NVARCHAR(500), [OWPHome] NVARCHAR(500), [OWPLeague] NVARCHAR(500), [OldAdminSiteMatchId] INT, [OldEventDate] DATETIME, [NewEventDate] DATETIME);
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
                DECLARE @NewAdminSiteMatchId INT, @AdminSiteAway NVARCHAR(500), @AdminSiteHome NVARCHAR(500), @AdminSiteLeague NVARCHAR(500), @OWPAway NVARCHAR(500), @OWPHome NVARCHAR(500), @OWPLeague NVARCHAR(500), @OldAdminSiteMatchId INT, @OldEventDate DATETIME, @NewEventDate DATETIME;
                SELECT TOP 1 @OSMatchId = OSMatchId, 
                             @NewAdminSiteMatchId = AdminSiteMatchId, 
                             @AdminSiteAway = AdminSiteAway, 
                             @AdminSiteHome = AdminSiteHome, 
                             @AdminSiteLeague = AdminSiteLeague, 
                             @OWPAway = OWPAway, 
                             @OWPHome = OWPHome, 
                             @OWPLeague = OWPLeague, 
                             @OldAdminSiteMatchId = NULL, 
                             @NewEventDate = NewEventDate, 
                             @OldEventDate = OldEventDate
                FROM #tmpTable
                WHERE OSMatchId > @OSMatchId
                ORDER BY OSMatchId;
                IF @@ROWCOUNT = 0
                    BREAK;
                DECLARE @oldData XML;
                DECLARE @newData XML;
                SET @oldData =
                (
                    SELECT @OWPAway AS '@a', 
                           @OWPHome AS '@h', 
                           @OWPLeague AS '@l', 
                           @OldAdminSiteMatchId AS '@aid', 
                           @OldEventDate AS '@e' FOR XML PATH('z'), ROOT('r')
                );
                SET @newData =
                (
                    SELECT @AdminSiteAway AS '@a', 
                           @AdminSiteHome AS '@h', 
                           @AdminSiteLeague AS '@l', 
                           @NewAdminSiteMatchId AS '@aid', 
                           @NewEventDate AS '@e' FOR XML PATH('z'), ROOT('r')
                );
                SET @OldLogData = REPLACE(CONVERT(NVARCHAR(MAX), @oldData), '" />', '"/"');
                SET @NewLogData = REPLACE(CONVERT(NVARCHAR(MAX), @newData), '" />', '"/"');
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