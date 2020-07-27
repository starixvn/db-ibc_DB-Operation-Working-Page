
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignment_GetHistorySuspenderToday]
AS
/*
Created: 20200527@Carlos.Nguyen
Task : Get history suspender today
DB: bodb_OWP

Revisions:
	20200527@Carlos.Nguyen: Initial SP - [Redmine: #126964]
*/
BEGIN
	SET NOCOUNT ON
	
	SELECT m.UserId,
		m.SpeakEnglish,
		m.SpeakChinese,
		m.InTime,
		m.OutTime
	FROM AutoAssignmentSuspenderHistory AS m WITH (NOLOCK)
END