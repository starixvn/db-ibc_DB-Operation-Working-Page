USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_TicketCreatorDetail_Get]    Script Date: 09/23/2021 11:18:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_TicketCreatorDetail_Get] @TicketId INT
AS
/*      
 Created: 20210917@Carlos.Nguyen
 Task : New ticket creator
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
*/
BEGIN
	SET NOCOUNT ON
	
	SELECT TOP 1 u.UserId,
		u.Username AS UserName,
		u.Nickname AS NickName
	FROM TicketCreator AS tc
		INNER JOIN [User] AS u ON tc.CreatorId=u.UserId
	WHERE tc.TicketId=@TicketId
END