
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_InsertNewIssue] @ActorId         INT, 
                                                              @Message         NVARCHAR(MAX), 
                                                              @OWPLeagueId     INT           = NULL, 
                                                              @InfoSiteMatchId INT           = NULL
AS

/*
Created: 20200909@Tyler
Task : Create new issue
DB: bodb_OWP

Revisions:
	20200909@Tyler: Init sync SP - [Redmine: #140620]
	20201003@Tyler: update other assignments  - [Redmine: #142258]  
	20201020@Esther: Remove EventDate  - [Redmine: #143792] 
	20201021@Esther: update table PreMatchIssueReceiver  - [Redmine: #143790]
	
*/

     SET NOCOUNT ON;
     DECLARE @issueId INT;
     DECLARE @estId INT;
     DECLARE @insertTime DATETIME= GETDATE();
     DECLARE @eventDate DATE= CAST(GETDATE() AS DATE);
     SELECT TOP 1 @estId = ResourceId
     FROM dbo.[RefResource] WITH(NOLOCK)
     WHERE RefName = N'Section'
           AND Value = N'EST';
     SELECT @issueId = PreMatchIssueId
     FROM [dbo].[PreMatchIssue] WITH(NOLOCK)
     WHERE(OWPLeagueId = @OWPLeagueId
           OR InfoSiteMatchId = @InfoSiteMatchId);

     -- If PreMatchIssue not exists
     IF @issueId IS NULL
         BEGIN
             INSERT INTO [dbo].[PreMatchIssue]
             ([OWPLeagueId], 
              [InfoSiteMatchId], 
              [IsDone]
             )
             VALUES
             (@OWPLeagueId, 
              @InfoSiteMatchId, 
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
                    SELECT DISTINCT 
                           @issueId, 
                           a.[UserId], 
                           0
                    FROM [dbo].[PreMatchAssignment] AS a WITH(NOLOCK)
                         INNER JOIN dbo.[PreMatchLeague] AS pl WITH(NOLOCK) ON pl.PreMatchLeagueId = a.PreMatchLeagueId
                         INNER JOIN dbo.[InfoSiteMatch] AS m WITH(NOLOCK) ON m.OWPLeagueId = pl.OWPLeagueId
                    WHERE(pl.OWPLeagueId = @OWPLeagueId
                          OR m.InfoSiteMatchId = @InfoSiteMatchId)
                         AND a.UserId <> @ActorId
                         AND a.UserId > 0
                         AND pl.EventDate = @eventDate
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