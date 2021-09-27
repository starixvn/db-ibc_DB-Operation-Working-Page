USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_TicketCenterEvent_Get]    Script Date: 09/23/2021 11:18:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE[dbo].[OWP_TicketCenterEvent_Get] @ActorId INT,
	@Keyword NVARCHAR(255) = NULL,
	@TicketId NVARCHAR(255) = NULL,
	@TicketTypeId INT = 0
AS
/*      
 ALTERd: 20210917@Carlos.Nguyen
 Task : New ticket issue event
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @tblTicketRecipient TABLE (TicketId INT)
	DECLARE @allTicketTypeId INT=0
	DECLARE @eventTicketTypeId INT=1
	
	INSERT INTO @tblTicketRecipient
	EXEC [dbo].[OWP_TicketCenter_GetTicketIdByRecipientId] @ActorId=@ActorId
	
	SELECT tbltk.TicketId,
	 owpl.OWPLeagueId,
	 owpl.OWPLeagueName,
	 tl.OwpHomeId,
	 tl.OwpAwayId,
	 ifm.HomeName,
	 ifm.AwayName,
	 tis.TicketType,
	 ty.TypeName,
	 tm.UserId,
	 tm.CreatedDate,
	 tm.[Message],
	 CASE WHEN u.Username IS NULL
		THEN u.Nickname
		ELSE u.Username
	 END AS Username
	FROM TicketIssue AS tis WITH (NOLOCK)
		INNER JOIN @tblTicketRecipient AS tbltk ON tbltk.TicketId=tis.TicketId
		INNER JOIN TicketType AS ty WITH (NOLOCK)ON tis.TicketType=ty.TypeId 
		INNER JOIN TicketIssueEvent AS tl WITH (NOLOCK) ON tis.TicketId=tl.TicketId
		INNER JOIN InfoSiteMatch AS ifm ON ifm.OWPHomeId=tl.OwpHomeId AND ifm.OWPAwayId=tl.OwpAwayId
		INNER JOIN TicketMessage AS tm WITH (NOLOCK)ON tis.TicketId=tm.TicketId
		INNER JOIN OWPLeague AS owpl WITH (NOLOCK) ON owpl.OWPLeagueId=tl.OwpLeagueId
		INNER JOIN [User] AS u WITH (NOLOCk) ON tm.UserId=u.UserId
	WHERE (@Keyword IS NULL OR
		@Keyword ='' OR
		owpl.OWPLeagueName LIKE '%'+@Keyword+'%' OR
		ifm.HomeName LIKE '%'+@Keyword+'%' OR
		ifm.AwayName LIKE '%'+@Keyword+'%')
		AND
		(
			@TicketId IS NULL OR
			@TicketId ='' OR
			CONVERT(VARCHAR(255), tbltk.TicketId) LIKE @TicketId+'%'
		)AND
		(
			@TicketTypeId=@allTicketTypeId OR
			tis.TicketType = @eventTicketTypeId
		)
END