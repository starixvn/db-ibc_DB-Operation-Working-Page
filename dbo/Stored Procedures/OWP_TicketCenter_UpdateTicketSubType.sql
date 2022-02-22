/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROC [dbo].[OWP_TicketCenter_UpdateTicketSubType] 
	@TicketId INT,
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

	UPDATE dbo.[TicketIssue]
	SET SubtypeId = @TicketSubTypeId
	WHERE TicketId = @TicketId;
END