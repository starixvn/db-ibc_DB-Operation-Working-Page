
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignment_GetLA] @RequestId NVARCHAR (50)
AS
/*
Created: @Carlos.Nguyen
Task : Get data LA for report
DB: bodb_OWP

Revisions:
	20191004@Carlos.Nguyen: Initial SP - [Redmine: #121452]	 
*/
BEGIN
	SELECT a.OWPMatchId,
		u.Username
	FROM dbo.AutoAssignmentResult AS a WITH(NOLOCK)
		INNER JOIN dbo.[User] AS u WITH (NOLOCK)
		ON a.RequestId=RequestId
	 
END