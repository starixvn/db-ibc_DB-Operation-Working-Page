
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignment_GetRequestExtra]
	@EventDate DATETIME
AS
/*
Created: 20200527@Carlos.Nguyen
Task : Get request extra
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
	WHERE req.EventDate IN (SELECT req1.EventDate
							FROM AutoAssignmentRequest req1 WITH (NOLOCK)
							WHERE req1.EventDate=@EventDate AND req1.Status=1)
END