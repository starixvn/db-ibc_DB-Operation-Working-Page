USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_TicketCenterEvent_GetUserIdsByTicketId]    Script Date: 09/23/2021 11:18:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_TicketCenterEvent_GetUserIdsByTicketId] 
	@TicketId INT
AS
/*      
 Created: 20210917@Carlos.Nguyen
 Task : get user id by ticket id
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
	20211006@Liam.Pham: Event ticket - [Redmine: #158037]
*/
BEGIN
	SET NOCOUNT ON
	
	-- Get all userId individual & belong to group
	SELECT reader.RecipientId
	FROM TicketMessageReader AS reader
	WHERE reader.TicketId=@TicketId
END