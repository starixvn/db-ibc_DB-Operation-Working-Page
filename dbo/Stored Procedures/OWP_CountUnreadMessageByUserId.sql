USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[dbo].[OWP_CountUnreadMessageByUserId]    Script Date: 01/06/2021 10:51:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_CountUnreadMessageByUserId] @UserId INT
AS
/*    
 Created: 20220217@Carlos.nguyen
 Task : Count unread message follow TicketId (because db store
 DB: bodb_OWP    
    
 Revisions:
	20220217@Carlos.nguyen: Initial SP - [Redmine: #168468]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @tblTicketMessageUnread TABLE(
		Total INT
	)
	
	-- Ticket order
	INSERT INTO @tblTicketMessageUnread(Total)
	SELECT COUNT (DISTINCT tis.TicketId)
	FROM TicketIssue AS tis WITH(NOLOCK)
	INNER JOIN TicketType AS ty WITH(NOLOCK) ON tis.TicketType = ty.TypeId
	INNER JOIN TicketIssueOther AS tl WITH(NOLOCK) ON tis.TicketId = tl.TicketId
	INNER JOIN TicketMessage AS tm WITH(NOLOCK) ON tis.TicketId = tm.TicketId
	INNER JOIN TicketMessageReader AS reader WITH(NOLOCK)
		ON tl.TicketId=reader.TicketId
	WHERE reader.IsRead=0 
		AND RecipientId=@UserId 
		AND GroupId IS NULL
	
	-- Ticket support
	INSERT INTO @tblTicketMessageUnread(Total)
	SELECT COUNT (DISTINCT tis.TicketId)
	FROM TicketIssue AS tis WITH(NOLOCK)
	INNER JOIN TicketType AS ty WITH(NOLOCK) ON tis.TicketType = ty.TypeId 
	INNER JOIN TicketIssueSupport AS ts WITH(NOLOCK) ON tis.TicketId = ts.TicketId
	INNER JOIN TicketMessage AS tm WITH(NOLOCK) ON tis.TicketId = tm.TicketId
	INNER JOIN TicketMessageReader AS reader WITH(NOLOCK)
		ON ts.TicketId=reader.TicketId
	WHERE reader.IsRead=0 
		AND RecipientId=@UserId 
		AND GroupId IS NULL
	
	-- Ticket event
	INSERT INTO @tblTicketMessageUnread(Total)
	SELECT COUNT (DISTINCT tis.TicketId)
	FROM TicketIssue AS tis WITH(NOLOCK)
	INNER JOIN TicketType AS ty WITH(NOLOCK) ON tis.TicketType = ty.TypeId 
	INNER JOIN TicketIssueEvent AS te WITH(NOLOCK) ON tis.TicketId = te.TicketId
	INNER JOIN InfoSiteMatch AS ifm ON ifm.InfoSiteMatchId = te.InfoSiteMatchId
	INNER JOIN OWPLeague AS owpl WITH(NOLOCK) ON owpl.OWPLeagueId = te.OwpLeagueId
	INNER JOIN TicketMessage AS tm WITH(NOLOCK) ON tis.TicketId = tm.TicketId
	INNER JOIN TicketMessageReader AS reader WITH(NOLOCK)
		ON te.TicketId=reader.TicketId
	WHERE reader.IsRead=0 
		AND RecipientId=@UserId 
		AND GroupId IS NULL
	
	-- Ticket event
	INSERT INTO @tblTicketMessageUnread(Total)
	SELECT COUNT (DISTINCT tis.TicketId)
	FROM TicketIssue AS tis WITH(NOLOCK)
	INNER JOIN TicketType AS ty WITH(NOLOCK) ON tis.TicketType = ty.TypeId 
	INNER JOIN TicketIssueLeague AS tl WITH(NOLOCK)ON tis.TicketId = tl.TicketId
	INNER JOIN OWPLeague AS owpl WITH(NOLOCK) ON owpl.OWPLeagueId = tl.OwpLeagueId
	INNER JOIN TicketMessage AS tm WITH(NOLOCK) ON tis.TicketId = tm.TicketId
	INNER JOIN TicketMessageReader AS reader WITH(NOLOCK)
		ON tl.TicketId=reader.TicketId
	WHERE reader.IsRead=0 
		AND RecipientId=@UserId 
		AND GroupId IS NULL
	
	SELECT SUM(Total)
	FROM @tblTicketMessageUnread
END