
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignmentRequest_GetAll]
AS
/*
Created: 20181221@Leo.Vo
Task : Get all requests
DB: bodb_OWP

Revisions:
	20181221@Leo.Vo: Initial SP - [Redmine: #106196]
*/
BEGIN
	SET NOCOUNT ON

	SELECT RequestId
		,EventDate
		,CreatedDate
		,[Status]
		,ISNULL(u.Nickname, u.Username) AS Creator
	FROM dbo.AutoAssignmentRequest AS r WITH (NOLOCK)
	INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON r.CreatorId = u.UserId
	ORDER BY CreatedDate DESC
END