
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignmentRequest_Api_GetStatusByRequestId] @RequestId VARCHAR(255)
AS
/*
Created: 20191227@Carlos.Nguyen
Task : Sp get status by request id
DB: bodb_OWP

Revisions:
	20191228@Carlos.Nguyen: Initial SP - [Redmine: #133428]
*/
BEGIN
	SET NOCOUNT ON

	SELECT r.Status
	FROM AutoAssignmentRequest AS r WITh (NOLOCK)
	WHERE r.RequestId=@RequestId
END