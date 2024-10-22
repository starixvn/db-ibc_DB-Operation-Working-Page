
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROC [dbo].[OWP_TicketCenter_UpdateTicketSubType] @TicketId        INT, 
                                                        @TicketSubTypeId INT
AS

/*
Created: 20220222@Luca
Task : Enhance Ticket Center
DB: bodb_OWP

Revisions:
	20220222@Luca: Create sp update ticket subtype - [Redmine: #168624]
*/

    BEGIN
        SET NOCOUNT ON;
        IF @TicketSubTypeId = 0
            BEGIN
                UPDATE dbo.[TicketIssue]
                  SET 
                      SubtypeId = NULL
                WHERE TicketId = @TicketId;
        END;
            ELSE
            BEGIN
                UPDATE dbo.[TicketIssue]
                  SET 
                      SubtypeId = @TicketSubTypeId
                WHERE TicketId = @TicketId;
        END;
    END;