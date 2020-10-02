USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_PreMatchAssignment_InsertNewIssue]    Script Date: 9/30/2020 5:18:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_InsertNewIssue] @ActorId         INT, 
                                                              @Message         NVARCHAR(MAX), 
                                                              @OWPLeagueId     INT           = NULL, 
                                                              @EventDate       DATE, 
                                                              @InfoSiteMatchId INT           = NULL
AS

/*
Created: 20200909@Tyler
Task : Create new issue
DB: bodb_OWP

Revisions:
	20200909@Tyler: Init sync SP - [Redmine: #140620]
	
*/

     SET NOCOUNT ON;
     DECLARE @issueId INT;
     DECLARE @estId INT;
     DECLARE @insertTime DATETIME= GETDATE();
     SELECT TOP 1 @estId = ResourceId
     FROM dbo.[RefResource] WITH(NOLOCK)
     WHERE RefName = N'Section'
           AND Value = N'EST';
     SELECT @issueId = PreMatchIssueId
     FROM [dbo].[PreMatchIssue] WITH(NOLOCK)
     WHERE(OWPLeagueId = @OWPLeagueId
           OR InfoSiteMatchId = @InfoSiteMatchId)
          AND EventDate = @EventDate;

     -- If PreMatchIssue not exists
     IF @issueId IS NULL
         BEGIN
             INSERT INTO [dbo].[PreMatchIssue]
             ([OWPLeagueId], 
              [InfoSiteMatchId], 
              [EventDate], 
              [IsDone]
             )
             VALUES
             (@OWPLeagueId, 
              @InfoSiteMatchId, 
              @EventDate, 
              0
             );
             SELECT @issueId = SCOPE_IDENTITY();

             -- Insert message
             INSERT INTO [dbo].[PreMatchIssueMessage]
             ([PreMatchIssueId], 
              [CreatedDate], 
              [UserId], 
              [Message]
             )
             VALUES
             (@issueId, 
              @insertTime, 
              @ActorId, 
              @Message
             );

             -- Insert receivers
             INSERT INTO [dbo].[PreMatchIssueReceiver]
             ([PreMatchIssueId], 
              [UserId], 
              [IsRead]
             )
                    SELECT @issueId, 
                           a.[UserId], 
                           0
                    FROM [dbo].[PreMatchAssignment] AS a WITH(NOLOCK)
                         INNER JOIN dbo.[PreMatchLeague] AS pl WITH(NOLOCK) ON pl.PreMatchLeagueId = a.PreMatchLeagueId
                         INNER JOIN dbo.[InfoSiteMatch] AS m WITH(NOLOCK) ON m.OWPLeagueId = pl.OWPLeagueId
                    WHERE (pl.OWPLeagueId = @OWPLeagueId OR m.InfoSiteMatchId = @InfoSiteMatchId)
                          AND pl.EventDate = @EventDate
                          AND a.UserId <> @ActorId
						  AND a.UserId > 0
                    UNION
                    SELECT @issueId, 
                           [UserId], 
                           0
                    FROM [dbo].[User] WITH(NOLOCK)
                    WHERE SectionId = @estId
                          AND UserId <> @ActorId
                    UNION
                    SELECT @issueId, 
                           @ActorId, 
                           1;
     END;
         ELSE
         BEGIN
             EXEC dbo.[OWP_PreMatchAssignment_InsertNewMessage] 
                  @ActorId, 
                  @Message, 
                  @PreMatchIssueId = @issueId;
     END;