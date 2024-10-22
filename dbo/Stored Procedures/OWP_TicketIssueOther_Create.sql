USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_TicketIssueOther_Create]    Script Date: 09/23/2021 11:18:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_TicketIssueOther_Create] @TicketId INT,
	@Subject NVARCHAR(2000)
AS
/*      
 Created: 20210917@Carlos.Nguyen
 Task : New ticket issue other
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
*/
BEGIN
	SET NOCOUNT ON
	INSERT INTO TicketIssueOther(
		TicketId,
		[Subject]
	 )
	VALUES (@TicketId,
		@Subject)
END