
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_InsertUpdateDeleteOtherAssignment] @ActorId          INT, 
                                                                                 @PreMatchLeagueId INT, 
                                                                                 @NewValue         NVARCHAR(30)  = '', 
                                                                                 @OldValue         NVARCHAR(30)  = '', 
                                                                                 @NewNoteValue     NVARCHAR(200) = '', 
                                                                                 @OldNoteValue     NVARCHAR(200) = '', 
                                                                                 @Bettype          INT, 
                                                                                 @IsTakeOver       BIT, 
                                                                                 @PreMatchIssueId  INT           = NULL
AS

/*
Created: 20200930@Tyler
Task : Pre-Match Other Assignment
DB: bodb_OWP

Revisions:
	20200930@Tyler: Init SP - [Redmine: #142258]
	
*/

     SET NOCOUNT ON;
     DECLARE @OWPLeagueId INT;
     DECLARE @eventDate DATE;
     SELECT @OWPLeagueId = OWPLeagueId, 
            @eventDate = EventDate
     FROM dbo.[PreMatchLeague] WITH(NOLOCK)
     WHERE PreMatchLeagueId = @PreMatchLeagueId;

     -- new assignment
     IF(@OldValue = ''
        AND @NewValue <> '')
         BEGIN
             EXEC [dbo].[OWP_PreMatchAssignment_InsertOtherAssignment] 
                  @ActorId, 
                  @PreMatchLeagueId, 
                  @NewValue, 
                  @OldValue, 
                  @NewNoteValue, 
                  @OldNoteValue, 
                  @Bettype, 
                  @IsTakeOver, 
                  @PreMatchIssueId;
         END;

     -- remove assignment
     IF(@OldValue <> ''
        AND @NewValue = '')
         BEGIN
             EXEC [dbo].[OWP_PreMatchAssignment_DeleteOtherAssignment] 
                  @ActorId, 
                  @PreMatchLeagueId, 
                  @NewValue, 
                  @OldValue, 
                  @NewNoteValue, 
                  @OldNoteValue, 
                  @Bettype, 
                  @IsTakeOver, 
                  @OWPLeagueId, 
                  @EventDate, 
                  @PreMatchIssueId;
         END;

     -- update assignment
     IF(@OldValue <> ''
        AND @NewValue <> ''
        AND @OldValue <> @NewValue)
         BEGIN
             EXEC [dbo].[OWP_PreMatchAssignment_UpdateOtherAssignment] 
                  @ActorId, 
                  @PreMatchLeagueId, 
                  @NewValue, 
                  @OldValue, 
                  @NewNoteValue, 
                  @OldNoteValue, 
                  @Bettype, 
                  @IsTakeOver, 
                  @OWPLeagueId, 
                  @EventDate, 
                  @PreMatchIssueId;
         END;

     -- update assignment note
     IF(@OldValue = @NewValue)
         BEGIN
             EXEC [dbo].[OWP_PreMatchAssignment_UpdateOtherAssignmentNote] 
                  @ActorId, 
                  @PreMatchLeagueId, 
                  @NewValue, 
                  @OldValue, 
                  @NewNoteValue, 
                  @OldNoteValue, 
                  @Bettype, 
                  @IsTakeOver, 
                  @PreMatchIssueId;
         END;