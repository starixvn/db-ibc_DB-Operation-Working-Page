USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_EventChecking_UpdateIssueIsDone]    Script Date: 9/15/2020 3:11:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventChecking_UpdateIssueIsDone] @ActorId         INT, 
                                                            @PreMatchIssueId INT
AS

/*
Created: 202000914@Tyler
Task : Update IsDone issue
DB: bodb_OWP

Revisions:
	202000914@Tyler: Init sync SP - [Redmine: #140620]
	
*/

     SET NOCOUNT ON;
     IF EXISTS
     (
         SELECT 1
         FROM dbo.[PreMatchIssue] WITH(NOLOCK)
         WHERE PreMatchIssueId = @PreMatchIssueId
               AND IsDone = 0
     )
         BEGIN
             DECLARE @StartRun DATETIME= GETDATE(), @EndRun DATETIME, @Duration INT, @LogData NVARCHAR(MAX), @LogDataOld NVARCHAR(MAX), @Xml XML;
             SET @Xml =
             (
                 SELECT PreMatchIssueId AS '@pmiid', 
                        IsDone AS '@d'
                 FROM dbo.[PreMatchIssue] WITH(NOLOCK)
                 WHERE PreMatchIssueId = @PreMatchIssueId FOR XML PATH('z'), ROOT('r')
             );
             SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');

             UPDATE dbo.[PreMatchIssue] WITH(ROWLOCK)
               SET 
                   IsDone = 1
             WHERE PreMatchIssueId = @PreMatchIssueId;

             SET @Xml =
             (
                 SELECT PreMatchIssueId AS '@pmiid', 
                        IsDone AS '@d'
                 FROM dbo.[PreMatchIssue] WITH(NOLOCK)
                 WHERE PreMatchIssueId = @PreMatchIssueId FOR XML PATH('z'), ROOT('r')
             );
             SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
             SET @EndRun = GETDATE();
             SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);

             EXEC dbo.OWP_WriteLog 
                  @CreatorId = @ActorId, 
                  @SPName = 'OWP_EventChecking_UpdateIssueIsDone', 
                  @LoggedDate = @StartRun, 
                  @Duration = @Duration, 
                  @ObjectId = @PreMatchIssueId, 
                  @DataOld = @LogDataOld, 
                  @Data = @LogData;
     END;