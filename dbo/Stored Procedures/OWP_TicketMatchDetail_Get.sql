USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_TicketMatchDetail_Get]    Script Date: 09/23/2021 11:18:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_TicketMatchDetail_Get] @TicketId INT
AS
/*      
 Created: 20210917@Carlos.Nguyen
 Task : Get ticket match detail
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
	20211018@Liam.Pham: Update ticket match detail - [Redmine: #158037]
	20211130@Mira: Get ticket status - [Redmine: #165017]
	20220222@Luca: Get TicketSubType - [Redmine: #168624]
	20220310@Liam: Save message  - [Redmine: #163767]		
*/
BEGIN
	SET NOCOUNT ON
	
	SELECT DISTINCT til.OWPLeagueId AS OwpLeagueId,
		owpl.OWPLeagueName,
		til.OwpHomeId,
		til.OwpAwayId,
		ifm.HomeName,
		ifm.AwayName,
		ti.TicketId,
		ti.TicketStatus,
		ti.TicketType,
		tt.TypeName,
		tm.CreatedDate,
		tm.Id AS MessageId,
		tm.[Message],
		tm.UserId,
		tm.FileId,
		ifm.EventDateTime AS KOTime,
		tm.IsSaved,
		CASE WHEN u.Nickname IS NULL
			THEN u.Username
			ELSE u.Nickname
		END AS Username,
		tst.SubtypeId AS TicketSubTypeId,
		tst.SubtypeName AS TicketSubTypeName
	FROM TicketIssue AS ti
	INNER JOIN TicketIssueEvent AS til ON ti.TicketId=til.TicketId
	INNER JOIN OWPLeague AS owpl ON owpl.OWPLeagueId=til.OwpLeagueId
	INNER JOIN TicketType AS tt ON tt.TypeId=ti.TicketType
	INNER JOIN TicketMessage AS tm ON tm.TicketId=ti.TicketId
	INNER JOIN [User] AS u ON u.UserId=tm.UserId
	INNER JOIN InfoSiteMatch AS ifm ON ifm.InfoSiteMatchId=til.InfoSiteMatchId
	LEFT JOIN TicketSubtype AS tst ON ti.TicketType = tst.TypeId AND ti.SubtypeId = tst.SubtypeId
	WHERE ti.TicketId=@TicketId
END