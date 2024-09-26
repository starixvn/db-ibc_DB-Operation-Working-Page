
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventChecking_InsertNewAddRequest] @ActorId INT, 
                                                              @Message NVARCHAR(MAX), 
                                                              @Subject NVARCHAR(500)
AS

/*
Created: 20201020@Mira
Task : Create new add request
DB: bodb_OWP

Revisions:
	20201020@Mira: Init SP - [Redmine: #140772]
	20201120@Mira: Modify Add New issue - [Redmine: #145568]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @issueId INT;
        DECLARE @earlyId INT;
        DECLARE @insertTime DATETIME= GETDATE();

        -- Select sessionId Early team
        SELECT TOP 1 @earlyId = ResourceId
        FROM dbo.[RefResource] WITH(NOLOCK)
        WHERE RefName = N'Section'
              AND Value = N'EST';

        -- Insert new issue
        INSERT INTO [dbo].[PreMatchIssue]
        ([OWPLeagueId], 
         [InfoSiteMatchId], 
         [IsDone]
        )
        VALUES
        (NULL, 
         NULL, 
         0
        );
        SELECT @issueId = SCOPE_IDENTITY();

        -- Insert new add request
        INSERT INTO [dbo].[NewAddRequest]
        ([Subject], 
         [PrematchIssueId]
        )
        VALUES
        (@Subject, 
         @issueId
        );

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
                      [UserId], 
                      0
               FROM [dbo].[User] WITH(NOLOCK)
               WHERE SectionId = @earlyId
                     AND UserId <> @ActorId
               UNION
               SELECT @issueId, 
                      @ActorId, 
                      1;
        SELECT @issueId AS 'PreMatchIssueId';
    END;