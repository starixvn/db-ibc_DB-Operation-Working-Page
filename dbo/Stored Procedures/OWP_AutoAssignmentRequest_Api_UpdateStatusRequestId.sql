
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignmentRequest_Api_UpdateStatusRequestId]
	@RequestId VARCHAR(MAX),
	@Status INT
AS
/*
Created: 20200324@Carlos.Nguyen
Task : Update status request
DB: bodb_OWP

Revisions:
	20200324@Carlos.Nguyen: Initial SP - [Redmine: #130957]
*/
BEGIN
	UPDATE AutoAssignmentRequest
	SET Status=@Status
	WHERE RequestId=@RequestId
END