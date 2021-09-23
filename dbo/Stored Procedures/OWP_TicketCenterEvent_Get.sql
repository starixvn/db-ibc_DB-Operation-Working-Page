USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_TicketCenterEvent_Get]    Script Date: 09/23/2021 11:18:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE[dbo].[OWP_TicketCenterEvent_Get] @ActorId INT,
	@MatchKeyword NVARCHAR(255) = NULL,
	@LeagueKeyword NVARCHAR(255) = NULL
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
	
	DECLARE @ticketIdActorBelong INT;
	
	DECLARE @tblTicketRecipient TABLE (TicketId INT)
	
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
	 tm.[Message]
	FROM TicketIssue AS tis WITH (NOLOCK)
		INNER JOIN @tblTicketRecipient AS tbltk ON tbltk.TicketId=tis.TicketId
		INNER JOIN TicketType AS ty WITH (NOLOCK)ON tis.TicketId=ty.TypeId 
		INNER JOIN TicketIssueEvent AS tl WITH (NOLOCK) ON tis.TicketId=tl.TicketId
		INNER JOIN InfoSiteMatch AS ifm ON ifm.OWPHomeId=tl.OwpHomeId AND ifm.OWPAwayId=tl.OwpAwayId
		INNER JOIN TicketMessage AS tm WITH (NOLOCK)ON tis.TicketId=tm.TicketId
		INNER JOIN OWPLeague AS owpl WITH (NOLOCK) ON owpl.OWPLeagueId=tl.OwpLeagueId
		INNER JOIN [User] AS u WITH (NOLOCk) ON tm.UserId=u.UserId
	WHERE (@LeagueKeyword IS NULL AND @MatchKeyword IS NULL) OR
	(@LeagueKeyword ='' AND @MatchKeyword ='') OR
		owpl.OWPLeagueName LIKE '%'+@LeagueKeyword+'%' OR
		ifm.HomeName LIKE '%'+@MatchKeyword+'%' OR
		ifm.AwayName LIKE '%'+@MatchKeyword+'%'
END