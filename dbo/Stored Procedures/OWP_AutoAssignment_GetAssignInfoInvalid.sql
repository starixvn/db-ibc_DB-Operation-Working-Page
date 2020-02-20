
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignment_GetAssignInfoInvalid] @EventDate DATE
AS
/*
Created: 2020110@Carlos.Nguyen
Task :Get assign info invalid
DB: bodb_OWP

Revisions:
	2020110@Carlos.Nguyen: Initial SP - [Redmine: #124448]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00')
		,@ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, - 1, @EventDate), '11:59:59')
	
	SELECT mi.OWPMatchId,
		mi.MatchStatus,
		ar.UserId
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
		INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK)ON om.OWPMatchId = mi.OWPMatchId
		INNER JOIN dbo.AutoAssignmentResult AS ar WITH (NOLOCK)ON ar.OWPMatchId=mi.OWPMatchId
	WHERE mi.MatchStatus IN ('Cancel','Postponed') AND
		om.EventDateTime BETWEEN @FromDate AND @ToDate
END