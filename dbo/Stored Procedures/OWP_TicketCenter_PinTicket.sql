/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_PinTicket] @ActorId  INT, 
                                                    @TicketId INT, 
                                                    @IsPinned BIT
AS

/*
Created: 20211208@Tyler
Task : Enhance TicketCenter
DB: bodb_OWP

Revisions:
	20211208@Tyler: pin ticket - [Redmine: 165017]
*/

    BEGIN
        SET NOCOUNT ON;
        UPDATE dbo.[TicketMessageReader]
          SET 
              IsPinned = @IsPinned
        WHERE RecipientId = @ActorId
              AND TicketId = @TicketId;
    END;