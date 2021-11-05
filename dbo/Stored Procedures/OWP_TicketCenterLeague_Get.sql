USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_TicketCenterLeague_Get]    Script Date: 09/23/2021 11:18:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_TicketCenterLeague_Get] @ActorId INT,
	@Keyword NVARCHAR(255) = NULL,
	@TicketId NVARCHAR(255) = NULL,
	@TicketTypeId INT = 0,
	@MarketKey INT=1
AS
/* 
 Created: 20210917@Carlos.Nguyen
 Task : New ticket issue league
 DB: bodb_OWP      
      
 Revisions:        
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
	20211104@Liam.Pham: fix duplicate messages - [Redmine: #162851]
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @tblTicketRecipient TABLE (TicketId INT)
	DECLARE @allTicketTypeId INT=0
	DECLARE @allMarketKey INT=1
	
	INSERT INTO @tblTicketRecipient
	EXEC [dbo].[OWP_TicketCenter_GetTicketIdByRecipientId] @ActorId=@ActorId
	
	SELECT DISTINCT tbltk.TicketId,
	 owpl.OWPLeagueId,
	 owpl.OWPLeagueName,
	 tis.TicketType,
	 ty.TypeName,
	 tm.UserId,
	 tm.CreatedDate,
	 tm.[Message],
	 tm.FileId,
	 tm.Id AS MessageId,
	 CASE WHEN u.Nickname IS NULL
		THEN u.Username
		ELSE u.Nickname
	 END AS Username,
	 reader.IsRead
	FROM TicketIssue AS tis WITH (NOLOCK)
		INNER JOIN @tblTicketRecipient AS tbltk ON tbltk.TicketId=tis.TicketId
		INNER JOIN TicketType AS ty WITH (NOLOCK)ON tis.TicketType=ty.TypeId 
		INNER JOIN TicketIssueLeague AS tl WITH (NOLOCK) ON tis.TicketId=tl.TicketId
		INNER JOIN TicketMessage AS tm WITH (NOLOCK)ON tis.TicketId=tm.TicketId
		INNER JOIN OWPLeague AS owpl WITH (NOLOCK) ON owpl.OWPLeagueId=tl.OwpLeagueId
		INNER JOIN [User] AS u WITH (NOLOCk) ON tm.UserId=u.UserId
		LEFT JOIN TicketMessageReader AS reader WITH (NOLOCK)ON tbltk.TicketId=reader.TicketId AND reader.RecipientId=@ActorId
	WHERE (@Keyword IS NULL OR
	@Keyword ='' OR
	owpl.OWPLeagueName LIKE '%'+@Keyword+'%')
	AND
		(
			@TicketId IS NULL OR
			@TicketId ='' OR
			CONVERT(VARCHAR(255), tbltk.TicketId) LIKE @TicketId+'%'
		)AND
		(
			@TicketTypeId=@allTicketTypeId OR
			tis.TicketType = @TicketTypeId
		)AND @MarketKey=@allMarketKey
END