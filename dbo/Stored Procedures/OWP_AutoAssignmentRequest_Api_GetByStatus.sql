
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignmentRequest_Api_GetByStatus]
AS
/*
Created: 20191227@Carlos.Nguyen
Task : Get by status
DB: bodb_OWP

Revisions:
	20191228@Carlos.Nguyen: Initial SP - [Redmine: #133428]
*/
BEGIN
	SET NOCOUNT ON
	SELECT RequestId
		,EventDate
	FROM dbo.AutoAssignmentRequest AS r WITH (NOLOCK)
	WHERE r.Status = 1
	ORDER BY r.Id ASC
	
	UPDATE dbo.AutoAssignmentRequest
	SET RequestDate = GETDATE(),
		Status=2
	WHERE Status=1
END