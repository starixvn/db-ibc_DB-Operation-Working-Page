
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_PreMatchAssignment_DeleteAssignment] @ActorId          INT, 
                                                                 @PreMatchLeagueId INT, 
                                                                 @NewValue         NVARCHAR(30) = '', 
                                                                 @OldValue         NVARCHAR(30) = '', 
                                                                 @Bettype          INT, 
                                                                 @IsTakeOver       BIT, 
                                                                 @PreMatchIssueId  INT          = NULL
AS

/*
Created: 20201003@Tyler
Task : Pre-Match Assignment
DB: bodb_OWP

Revisions:
	20201003@Tyler: update other assignments  - [Redmine: #142258]  
	
*/

     SET NOCOUNT ON;
     DECLARE @userId INT;
     DECLARE @StartRun DATETIME= GETDATE(), @EndRun DATETIME, @Duration INT, @LogData NVARCHAR(MAX), @LogDataOld NVARCHAR(MAX), @Xml XML;
     CREATE TABLE #tblMatchIssues(PreMatchIssueId INT);

     -- temp table
     INSERT INTO #tblMatchIssues(PreMatchIssueId)
            SELECT i.PreMatchIssueId
            FROM [dbo].[InfoSiteMatch] AS m WITH(NOLOCK)
                 INNER JOIN PreMatchLeague AS pl WITH(NOLOCK) ON pl.OWPLeagueId = m.OWPLeagueId
                 INNER JOIN PreMatchIssue AS i ON i.InfoSiteMatchId = m.InfoSiteMatchId
            WHERE pl.PreMatchLeagueId = @PreMatchLeagueId
                  AND m.EventDateTime BETWEEN DATEADD(DAY, DATEDIFF(DAY, 0, pl.EventDate), '12:00:00') AND DATEADD(DAY, DATEDIFF(DAY, -1, pl.EventDate), '11:59:59');

     --
     SET @Xml = (
     SELECT pa.PreMatchLeagueId AS '@plid', 
            pa.UserId AS '@uid', 
            pa.Bettype AS '@bt', 
            pa.IsTakeOver AS '@ito', 
            u.Username AS '@un'
     FROM dbo.[PreMatchAssignment] AS pa WITH(NOLOCK)
          INNER JOIN dbo.[User] AS u ON pa.UserId = u.UserId
     WHERE PreMatchLeagueId = @PreMatchLeagueId
           AND Bettype = @Bettype
           AND IsTakeOver = @IsTakeOver
           AND AssignmentType = 1 FOR XML PATH('z'), ROOT('r'));

     --
     SELECT @userId = UserId
     FROM dbo.[PreMatchAssignment]
     WHERE PreMatchLeagueId = @PreMatchLeagueId
           AND Bettype = @Bettype
           AND IsTakeOver = @IsTakeOver
           AND AssignmentType = 1;

     -- delete from receiving isssue message
     DELETE r
     FROM [dbo].[PreMatchIssueReceiver] AS r
     WHERE @PreMatchIssueId IS NOT NULL
           AND r.PreMatchIssueId = @PreMatchIssueId
           AND r.UserId = @userId
           AND r.UserId NOT IN
     (
         SELECT UserId
         FROM dbo.[PreMatchIssueMessage] WITH(NOLOCK)
         WHERE PreMatchIssueId = @PreMatchIssueId
     );
     DELETE r
     FROM [dbo].[PreMatchIssueReceiver] AS r
          INNER JOIN #tblMatchIssues AS i ON i.PreMatchIssueId = r.PreMatchIssueId
     WHERE r.UserId = @userId
           AND r.UserId NOT IN
     (
         SELECT UserId
         FROM dbo.[PreMatchIssueMessage] WITH(NOLOCK)
         WHERE PreMatchIssueId = @PreMatchIssueId
     );

     -- delete asssignment
     DELETE FROM dbo.[PreMatchAssignment]
     WHERE PreMatchLeagueId = @PreMatchLeagueId
           AND Bettype = @Bettype
           AND IsTakeOver = @IsTakeOver
           AND AssignmentType = 1;

     -- Log
     SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
     SET @EndRun = GETDATE();
     SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
     EXEC dbo.OWP_WriteLog 
          @CreatorId = @ActorId, 
          @SPName = 'OWP_PreMatchAssignment_InsertUpdateDeleteAssignment', 
          @LoggedDate = @StartRun, 
          @Duration = @Duration, 
          @ObjectId = @preMatchLeagueId, 
          @DataOld = @LogDataOld, 
          @Data = @LogData;