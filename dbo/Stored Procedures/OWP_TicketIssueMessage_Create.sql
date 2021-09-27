USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_TicketIssueMessage_Create]    Script Date: 09/23/2021 11:18:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE[dbo].[OWP_TicketIssueMessage_Create] @TicketId INT,
	@Message NVARCHAR(2000),
	@UserId INT,
	@IsSaved BIT
AS
/*      
 ALTERd: 20210917@Carlos.Nguyen
 Task : New ticket issue message
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
*/
BEGIN
	SET NOCOUNT ON
	INSERT INTO TicketMessage(
		TicketId,
		CreatedDate,
		[Message],
		UserId,
		IsSaved 
	 )
	VALUES (
		@TicketId,
		DATEADD(HOUR, 12, GETDATE()),
		@Message,
		@UserId,
		0
	)
	SELECT MAX(tm.Id)
	FROM TicketMessage AS tm
END