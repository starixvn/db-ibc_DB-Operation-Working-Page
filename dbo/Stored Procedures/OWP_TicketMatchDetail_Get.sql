USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_TicketMatchDetail_Get]    Script Date: 09/23/2021 11:18:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE[dbo].[OWP_TicketMatchDetail_Get] @TicketId INT
AS
/*      
 ALTERd: 20210917@Carlos.Nguyen
 Task : Get ticket match detail
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
*/
BEGIN
	SET NOCOUNT ON
	
	SELECT DISTINCT til.OWPLeagueId AS OwpLeagueId,
		owpl.OWPLeagueName,
		til.OwpAwayId,
		til.OwpAwayId,
		ifm.HomeName,
		ifm.AwayName,
		ti.TicketId,
		ti.TicketType,
		tt.TypeName,
		tm.CreatedDate,
		tm.Id AS MessageId,
		tm.[Message],
		tm.UserId,
		ifm.EventDateTime AS KOTime,
		CASE WHEN u.Nickname IS NULL
			THEN u.Username
			ELSE u.Nickname
		END AS Username
	FROM TicketIssue AS ti
	INNER JOIN TicketIssueEvent AS til ON ti.TicketId=til.TicketId
	INNER JOIN OWPLeague AS owpl ON owpl.OWPLeagueId=til.OwpLeagueId
	INNER JOIN TicketType AS tt ON tt.TypeId=ti.TicketType
	INNER JOIN TicketMessage AS tm ON tm.TicketId=ti.TicketId
	INNER JOIN [User] AS u ON u.UserId=tm.UserId
	INNER JOIN InfoSiteMatch AS ifm ON ifm.OWPHomeId=til.OwpAwayId AND
	 ifm.OWPAwayId=til.OwpAwayId AND
	 ifm.OWPLeagueId=til.OwpLeagueId
	WHERE ti.TicketId=@TicketId
END