
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignment_GetHistoryMatchToday]
AS
/*
Created: 20200527@Carlos.Nguyen
Task : Get history match today
DB: bodb_OWP

Revisions:
	20200527@Carlos.Nguyen: Initial SP - [Redmine: #126964]
*/
BEGIN
	SET NOCOUNT ON
	
	SELECT m.MatchId,
		m.Bettype,
		m.KOTime,
		m.OtherTime,
		m.Venue,
		m.MaxBet
	FROM AutoAssignmentMatchHistory AS m WITH (NOLOCK)
END