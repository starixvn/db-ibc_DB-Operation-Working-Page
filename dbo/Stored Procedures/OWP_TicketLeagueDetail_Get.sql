USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_TicketLeagueDetail_Get]    Script Date: 09/23/2021 11:18:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_TicketLeagueDetail_Get]
	@TicketId INT
AS
/*      
 Created: 20210917@Carlos.Nguyen
 Task : Get ticket league detail
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
*/
BEGIN
	SET NOCOUNT ON
	
	SELECT DISTINCT til.OWPLeagueId AS OwpLeagueId,
		owpl.OWPLeagueName,
		ti.TicketId,
		ti.TicketType,
		tt.TypeName,
		tm.CreatedDate,
		tm.Id AS MessageId,
		tm.[Message],
		tm.UserId,
		tm.FileId,
		CASE WHEN u.Nickname IS NULL
			THEN u.Username
			ELSE u.Nickname
		END AS Username
	FROM TicketIssue AS ti
	INNER JOIN TicketIssueLeague AS til ON ti.TicketId=til.TicketId
	INNER JOIN OWPLeague AS owpl ON owpl.OWPLeagueId=til.OwpLeagueId
	INNER JOIN TicketType AS tt ON tt.TypeId=ti.TicketType
	INNER JOIN TicketMessage AS tm ON tm.TicketId=ti.TicketId
	INNER JOIN [User] AS u ON u.UserId=tm.UserId
	WHERE ti.TicketId=@TicketId
END