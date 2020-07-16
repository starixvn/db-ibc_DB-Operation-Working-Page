
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
	
	DECLARE @eventDateGetRequest DATE
	
	SELECT TOP 1 @eventDateGetRequest=req.EventDate
		FROM AutoAssignmentRequest AS req WITH (NOLOCK)
		WHERE req.EventDate=@EventDate AND req.Status=1
	
	SELECT req.RequestId,
		req.EventDate,
		req.CreatedDate
	FROM AutoAssignmentRequest AS req WITH (NOLOCK)
	WHERE req.EventDate = @eventDateGetRequest
END