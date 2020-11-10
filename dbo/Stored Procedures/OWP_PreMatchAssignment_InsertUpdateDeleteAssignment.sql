
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_InsertUpdateDeleteAssignment] @ActorId          INT, 
                                                                            @PreMatchLeagueId INT, 
                                                                            @NewValue         NVARCHAR(30) = '', 
                                                                            @OldValue         NVARCHAR(30) = '', 
                                                                            @Bettype          INT, 
                                                                            @IsTakeOver       BIT, 
                                                                            @AssignmentType   INT, 
                                                                            @PreMatchIssueId  INT          = NULL
AS

/*
Created: 20200817@Tyler
Task : Pre-Match Assignment
DB: bodb_OWP

Revisions:
	20200817@Tyler: Init sync SP - [Redmine: #138643]
	20200914@Tyler: Update issue receiver - [Redmine: #140620]
	20201003@Tyler: update other assignments  - [Redmine: #142258]  
	20201110@Tyler: remove other assignment note - [Redmine: #144948]
	
*/

    BEGIN
        DECLARE @OWPLeagueId INT;
        DECLARE @eventDate DATE;
        SELECT @OWPLeagueId = OWPLeagueId, 
               @eventDate = EventDate
        FROM dbo.[PreMatchLeague] WITH(NOLOCK)
        WHERE PreMatchLeagueId = @PreMatchLeagueId;
        -- 
        IF(@OldValue = ''
           AND @NewValue <> '')
            BEGIN
                EXEC [dbo].[OWP_PreMatchAssignment_InsertAssignment] 
                     @ActorId = @ActorId, 
                     @PreMatchLeagueId = @PreMatchLeagueId, 
                     @NewValue = @NewValue, 
                     @OldValue = @OldValue, 
                     @Bettype = @Bettype, 
                     @IsTakeOver = @IsTakeOver, 
					 @AssignmentType = @AssignmentType,
                     @PreMatchIssueId = @PreMatchIssueId;
            END;

        --
        IF(@OldValue <> ''
           AND @NewValue = '')
            BEGIN
                EXEC [dbo].[OWP_PreMatchAssignment_DeleteAssignment] 
                     @ActorId = @ActorId, 
                     @PreMatchLeagueId = @PreMatchLeagueId, 
                     @NewValue = @NewValue, 
                     @OldValue = @OldValue, 
                     @Bettype = @Bettype, 
                     @IsTakeOver = @IsTakeOver, 
                     @PreMatchIssueId = @PreMatchIssueId, 
                     @EventDate = @eventDate, 
                     @OWPLeagueId = @OWPLeagueId,
					 @AssignmentType = @AssignmentType;
            END;

        --
        IF(@OldValue <> ''
           AND @NewValue <> '')
            BEGIN
                EXEC [dbo].[OWP_PreMatchAssignment_UpdateAssignment] 
                     @ActorId = @ActorId, 
                     @PreMatchLeagueId = @PreMatchLeagueId, 
                     @NewValue = @NewValue, 
                     @OldValue = @OldValue, 
                     @Bettype = @Bettype, 
                     @IsTakeOver = @IsTakeOver, 
                     @PreMatchIssueId = @PreMatchIssueId, 
                     @EventDate = @eventDate, 
                     @OWPLeagueId = @OWPLeagueId,
					 @AssignmentType = @AssignmentType;
            END;
    END;