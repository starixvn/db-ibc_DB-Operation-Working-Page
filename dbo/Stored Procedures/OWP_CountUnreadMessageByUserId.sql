USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[dbo].[OWP_CountUnreadMessageByUserId]    Script Date: 01/06/2021 10:51:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_CountUnreadMessageByUserId] @UserId INT
AS
/*    
 Created: 20220217@Carlos.nguyen
 Task : CountUnreadMessage
 DB: bodb_OWP    
    
 Revisions:
	20220217@Carlos.nguyen: Initial SP - [Redmine: #168468]
*/
BEGIN
	SET NOCOUNT ON

	SELECT COUNT(Id)
	FROM TicketMessageReader
	WHERE RecipientId=@UserId
	AND IsRead=0
	AND GroupId IS NULL
END