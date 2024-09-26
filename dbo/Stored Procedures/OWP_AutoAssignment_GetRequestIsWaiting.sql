
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignment_GetRequestIsWaiting]
	@EventDate DATETIME
AS
/*
Created: 20200526@Carlos.Nguyen
Task : Get request is waiting
DB: bodb_OWP

Revisions:
	20200526@Carlos.Nguyen: Initial SP - [Redmine: #126964]
*/
BEGIN
	SET NOCOUNT ON
	
	SELECT req.RequestId
	FROM AutoAssignmentRequest AS req WITH (NOLOCK)
	WHERE req.EventDate=@EventDate AND req.Status IN (1,2)
END