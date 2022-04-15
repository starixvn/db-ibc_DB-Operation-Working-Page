
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_DeleteOldData] @Date DATETIME
AS

/*    
 Created: 20200819@Mira
 Task : Delete old data
 DB: bodb_OWP    
    
 Revisions:
	20200819@Mira: Archive plan for OWP tables - [Redmine: #137757]	
	20200830@Jacob: Delete Old data of EmployeeWorkingShiftNote] - [Redmine: #137757]	
	20200918@Carlos.Nguyen: Auto reassign/ Remove script delete old data AutoAssignmentSuspenderHistory - [Redmine: #126964]
	20201201@Tyler: delete file upload  - [Redmine: #145591]
	20220329@Carlos.nguyen : Delete script unuse - [Redmine: #166030]
	20220415@Luca.Duong: change table AutoAssignmentResult to InfoSiteAutoAssignmentResult [Redmine: #171297]
*/

    BEGIN
        SET NOCOUNT ON;
        -- DO NOT ALLOW TO DELETE DATA IN 30 DAYS
        IF DATEDIFF(DAY, @Date, GETDATE()) < 30
            BEGIN
                RETURN;
            END;
        DECLARE @FromDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @Date), '12:00:00');
        DECLARE @ToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @Date) + 1, '11:59:59');

        -- Temp table
        CREATE TABLE #MatchIds
        (Id INT
        );
        INSERT INTO #MatchIds(Id)
               SELECT OWPMatchId
               FROM dbo.OWPMatch
               WHERE EventDateTime BETWEEN @FromDateTime AND @ToDateTime;
        CREATE TABLE #MatchNoteIds(Id INT);
        INSERT INTO #MatchNoteIds(Id)
               SELECT MatchNoteId
               FROM dbo.MatchNote m WITH(NOLOCK)
                    INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id;
        CREATE TABLE #MatchRecommendOddsIds(Id INT);
        INSERT INTO #MatchRecommendOddsIds(Id)
               SELECT MatchRecommendOddsId
               FROM dbo.MatchRecommendOdds m WITH(NOLOCK)
                    INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id;

        -- DELETE UserLog
        DELETE FROM dbo.UserLog
        WHERE LoggedDate BETWEEN @FromDateTime AND @ToDateTime;

        -- DELETE InfoSiteAutoAssignmentResult            
        DELETE m
        FROM dbo.InfoSiteAutoAssignmentResult m
             INNER JOIN dbo.AutoAssignmentRequest t ON m.RequestId = t.RequestId
        WHERE EventDate BETWEEN @FromDateTime AND @ToDateTime;

        -- DELETE AutoAssignmentRequest
        DELETE m
        FROM dbo.AutoAssignmentRequest m
        WHERE EventDate = @Date;

        -- DELETE AssignmentUploadHistory
        DELETE FROM dbo.AssignmentUploadHistory
        WHERE EventDate = @Date;

        -- DELETE ReadyTradeStatus
        DELETE FROM dbo.ReadyTradeStatus
        WHERE ReadyDateTime BETWEEN @FromDateTime AND @ToDateTime;

        

        -- DELETE InfoSiteSyncLog
        DELETE m
        FROM dbo.InfoSiteSyncLog m WITH(NOLOCK)
             INNER JOIN dbo.InfoSiteSyncLogDetail i ON i.LogId = m.LogId
             INNER JOIN dbo.InfoSiteMatch a ON a.InfoSiteMatchId = i.InfoSiteMatchId
        WHERE a.EventDateTime BETWEEN @FromDateTime AND @ToDateTime;

        -- DELETE EmployeeWorkingShift
        DELETE FROM dbo.EmployeeWorkingShift
        WHERE ShiftDate = @Date;

        -- DELETE EmployeeWorkingShiftNote_Old
        DELETE FROM dbo.[EmployeeWorkingShiftNote]
        WHERE ShiftDate BETWEEN @FromDateTime AND @ToDateTime;

        -- DELETE OWPMatch
        DELETE m
        FROM dbo.OWPMatch m
             INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id;

        -- DELETE MatchAgent
        DELETE m
        FROM dbo.MatchAgent m
             INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id;

        -- DELETE MatchInfo
        DELETE m
        FROM dbo.MatchInfo m
             INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id;

        -- DELETE MatchMarket
        DELETE m
        FROM dbo.MatchMarket m
             INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id;

        -- DELETE MatchNote
        DELETE m
        FROM dbo.MatchNote m
             INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id;

        -- DELETE MatchNoteUser
        DELETE m
        FROM dbo.MatchNoteUser m
             INNER JOIN #MatchNoteIds i ON m.MatchNoteId = i.Id;

        -- DELETE MatchOfferDetail
        DELETE m
        FROM dbo.MatchOfferDetail m
             INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id;

        -- DELETE MatchOtherProvider
        DELETE m
        FROM dbo.MatchOtherProvider m
             INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id;

        -- DELETE MatchProvider
        DELETE m
        FROM dbo.MatchProvider m
             INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id;

        -- DELETE MatchRecommendOdds
        DELETE m
        FROM dbo.MatchRecommendOdds m
             INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id;

        -- DELETE MatchRecommendOddsDetail
        DELETE m
        FROM dbo.MatchRecommendOddsDetail m
             INNER JOIN #MatchRecommendOddsIds i ON m.MatchRecommendOddsId = i.Id;

        -- DELETE MatchSetting
        DELETE m
        FROM dbo.MatchSetting m
             INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id;

        -- DELETE MatchTelevision
        DELETE m
        FROM dbo.MatchTelevision m
             INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id;

        -- DELETE MinorMatch
        DELETE m
        FROM dbo.MinorMatch m
             INNER JOIN #MatchIds i ON m.MinorMatchId = i.Id;
        DELETE m
        FROM dbo.MinorMatch m
             INNER JOIN #MatchIds i ON m.ParentMatchId = i.Id;

        -- DELETE Assignment
        DELETE m
        FROM dbo.Assignment m
             INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id;

        -- DELETE FileUpload
        DELETE m
        FROM dbo.FileUpload m
        WHERE m.CreatedDate BETWEEN @FromDateTime AND @ToDateTime;

        -- DROP Temp Table
        DROP TABLE #MatchIds;
        DROP TABLE #MatchNoteIds;
        DROP TABLE #MatchRecommendOddsIds;
    END;