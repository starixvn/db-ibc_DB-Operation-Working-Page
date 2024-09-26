
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OtherSport_UpdateLinkedMatches] @LinkedMatches NVARCHAR(MAX)
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
        DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT, @OldLogData NVARCHAR(MAX);
        SET @StartRun = GETDATE();
        DECLARE @idoc INT;
        CREATE TABLE #tmpTable
        (OSMatchId           INT, 
         AdminSiteMatchId    INT NULL, 
         OWPAway             NVARCHAR(500), 
         OWPHome             NVARCHAR(500), 
         OWPLeague           NVARCHAR(500), 
         OldAdminSiteMatchId INT NULL, 
         OldEventDate        DATETIME
        );
        EXEC sp_xml_preparedocument 
             @idoc OUTPUT, 
             @LinkedMatches;
        INSERT INTO #tmpTable
        (OSMatchId, 
         AdminSiteMatchId, 
         OWPAway, 
         OWPHome, 
         OWPLeague, 
         OldAdminSiteMatchId, 
         OldEventDate
        )
               SELECT OSMatchId, 
                      NULL, 
                      OWPAway, 
                      OWPHome, 
                      OWPLeague, 
                      OldAdminSiteMatchId, 
                      OldEventDate
               FROM OPENXML(@idoc, '/Root/LinkedMatch', 1) WITH([OSMatchId] INT, [OWPAway] NVARCHAR(500), [OWPHome] NVARCHAR(500), [OWPLeague] NVARCHAR(500), [OldAdminSiteMatchId] INT, [OldEventDate] DATETIME);

        -- Update info
        UPDATE m
          SET 
              m.AdminSiteMatchId = t.AdminSiteMatchId
        FROM OSMatch m
             INNER JOIN #tmpTable t ON m.OSMatchId = t.OSMatchId
        WHERE ISNULL(m.AdminSiteMatchId, 0) <> 0;

        -- LOG
        DECLARE @OSMatchId INT= 0;
        WHILE(1 = 1)
            BEGIN
                DECLARE @OWPAway NVARCHAR(500), @OWPHome NVARCHAR(500), @OWPLeague NVARCHAR(500), @OldAdminSiteMatchId INT, @OldEventDate DATETIME;
                SELECT TOP 1 @OSMatchId = OSMatchId, 
                             @OWPAway = OWPAway, 
                             @OWPHome = OWPHome, 
                             @OWPLeague = OWPLeague, 
                             @OldAdminSiteMatchId = OldAdminSiteMatchId, 
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
                SET @OldLogData = REPLACE(CONVERT(NVARCHAR(MAX), @oldData), '" />', '"/"');
                SET @EndRun = GETDATE();
                SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
                EXEC dbo.OWP_WriteLog 
                     @CreatorId = 0, 
                     @SPName = 'OWP_OtherSport_UpdateLinkedMatches', 
                     @LoggedDate = @StartRun, 
                     @Duration = @Duration, 
                     @ObjectId = @OSMatchId, 
                     @DataOld = @OldLogData;
            END;
        DROP TABLE #tmpTable;
        EXEC sp_xml_removedocument 
             @idoc;
    END;