USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_TicketIssueEvent_Create]    Script Date: 09/23/2021 11:18:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_TicketIssueEvent_Create] @TicketId INT,
	@OwpLeagueId INT,
	@OwpHomeId INT = NULL,
	@OwpAwayId INT = NULL,
	@InfoSiteMatchId INT = NULL
AS
/*      
 Created: 20210917@Carlos.Nguyen
 Task : New ticket issue event
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
	20211015@Liam.Pham: update create ticket event - [Redmine: #158037]
*/

BEGIN
	SET NOCOUNT ON
	INSERT INTO TicketIssueEvent(
		TicketId,
		OwpLeagueId ,
		OwpHomeId ,
		OwpAwayId ,
		InfoSiteMatchId
	 )
	VALUES(@TicketId,
		@OwpLeagueId ,
		@OwpHomeId ,
		@OwpAwayId,
		@InfoSiteMatchId
		)
END