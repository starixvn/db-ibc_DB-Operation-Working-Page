USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_TicketIssueSupport_Create]    Script Date: 12/31/2021 10:46:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_TicketIssueSupport_Create] @TicketId INT,
	@Subject NVARCHAR(2000)
AS
/*      
 Created: 20211231@Johnny.Thai
 Task : New ticket issue other
 DB: bodb_OWP      
      
 Revisions:          
	20211231@Johnny.Thai: Event ticket - [Redmine: #158037]
*/
BEGIN
	SET NOCOUNT ON
	INSERT INTO TicketIssueSupport(
		TicketId,
		[Subject]
	 )
	VALUES (@TicketId,
		@Subject)
END
