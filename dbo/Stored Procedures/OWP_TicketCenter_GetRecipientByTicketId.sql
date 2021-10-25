USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_TicketCenter_GetRecipientByTicketId]    Script Date: 09/30/2021 11:20:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_TicketCenter_GetRecipientByTicketId]
	@TicketId INT
AS
/*      
 Created: 20210917@Carlos.Nguyen
 Task : Get recipient ticket
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @tblRecipient TABLE(
		RecipientId INT,
		GroupName NVARCHAR(2000),
		UserName NVARCHAR(255),
		NickName NVARCHAR(255),
		RecipientType INT
	)
	
	INSERT INTO @tblRecipient(
		RecipientId,
		GroupName,
		UserName,
		NickName,
		RecipientType
	)
	
	SELECT DISTINCT tr.RecipientId,
		GroupName = NULL,
		u.Username,
		u.Nickname,
		RecipientType = 1
	FROM TicketRecipient AS tr
	INNER JOIN [User] AS u ON u.UserId=tr.RecipientId
	WHERE tr.RecipientType=1 AND tr.TicketId=@TicketId
	UNION
	SELECT DISTINCT tr.RecipientId,
		g.GroupName,
		Username=NULL,
		Nickname=NULL,
		RecipientType = 2
	FROM TicketRecipient AS tr
		INNER JOIN TicketGroup AS g ON g.GroupId=tr.RecipientId
	WHERE tr.RecipientType=2 AND tr.TicketId=@TicketId
	
	SELECT RecipientId,
		GroupName,
		UserName,
		NickName,
		RecipientType
	FROM @tblRecipient
END