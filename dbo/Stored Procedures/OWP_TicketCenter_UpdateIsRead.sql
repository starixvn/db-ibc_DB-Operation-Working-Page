USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_TicketCenter_UpdateIsRead]    Script Date: 09/23/2021 11:18:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE[dbo].[OWP_TicketCenter_UpdateIsRead] 
	@TicketId INT,
	@IsRead BIT = NULL
AS
/*      
 ALTERd: 20210917@Carlos.Nguyen
 Task : Upate is read
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
*/
BEGIN
	SET NOCOUNT ON
	
	UPDATE TicketRecipient
	SET IsRead=@IsRead
	WHERE TicketId=@TicketId
END