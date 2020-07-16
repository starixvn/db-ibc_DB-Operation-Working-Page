
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignment_GetRequestNew]
AS
/*
Created: 20200527@Carlos.Nguyen
Task : Get request new
DB: bodb_OWP

Revisions:
	20200527@Carlos.Nguyen: Initial SP - [Redmine: #126964]
*/
BEGIN
	SET NOCOUNT ON
	
	SELECT req.RequestId,
		req.EventDate,
		req.CreatedDate
	FROM AutoAssignmentRequest AS req WITH (NOLOCK)
	WHERE req.EventDate IN (SELECT re.EventDate
							FROM AutoAssignmentRequest AS re WITH (NOLOCK)
							WHERE re.Status=1)
END