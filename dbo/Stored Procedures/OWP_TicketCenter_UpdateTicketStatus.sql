
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_UpdateTicketStatus] @TicketId     INT, 
                                                            @TicketStatus VARCHAR(10), 
                                                            @ModifiedBy   INT
AS

/*
Created: 20211130@Mira
Task : Enhance Ticket Center
DB: bodb_OWP

Revisions:
	20211130@Mira: Add ticket status - [Redmine: #165017]
	20220110@Mira: Enhance ticket status - [Redmine: #165017]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @LogDate DATETIME= DATEADD(HOUR, 12, CONVERT(DATETIME, GETDATE()));

        -- Save status log
        INSERT INTO dbo.[TicketStatusLog]
        (LogDate, 
         TicketId, 
         ModifiedBy, 
         OldValue, 
         NewValue
        )
               SELECT @LogDate, 
                      @TicketId, 
                      @ModifiedBy, 
                      t.TicketStatus, 
                      @TicketStatus
               FROM dbo.[TicketIssue] t
               WHERE t.TicketId = @TicketId
                     AND @ModifiedBy > 0
                     AND t.TicketStatus <> @TicketStatus;

        -- Update Status
        UPDATE dbo.[TicketIssue]
          SET 
              TicketStatus = @TicketStatus
        WHERE TicketId = @TicketId
              AND @ModifiedBy > 0
              AND TicketStatus <> @TicketStatus;
    END;