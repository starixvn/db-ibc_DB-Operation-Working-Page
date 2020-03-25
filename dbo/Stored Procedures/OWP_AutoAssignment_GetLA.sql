
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignment_GetLA]
@EventDate DATE
--@RequestId NVARCHAR (MAX)
AS
/*
Created: @Carlos.Nguyen
Task : Get data LA for report
DB: bodb_OWP

Revisions:
	20191004@Carlos.Nguyen: Initial SP - [Redmine: #121452]	 
*/
BEGIN
	
	DECLARE @ResponseDateMax VARCHAR(500),
		@RequestId VARCHAR(MAX)
	
	SELECT @ResponseDateMax= MAX(au.ResponseDate)
	FROM AutoAssignmentRequest AS au WITH(NOLOCK)
	WHERE au.EventDate=@EventDate
	
	SELECT @RequestId= au.RequestId
	FROM AutoAssignmentRequest AS au WITH(NOLOCK)
	WHERE au.EventDate=@ResponseDateMax
	
	
	SELECT ISNULL(m.MinorMatchId, au.OWPMatchId) AS OWPMatchId
		,u.Username
	FROM dbo.AutoAssignmentResult AS au WITH(NOLOCK)
	INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON au.UserId = u.UserId
	LEFT JOIN dbo.MinorMatch AS m WITH (NOLOCK) On m.ParentMatchId = au.OWPMatchId AND m.MinorBettypeId = au.Bettype
	WHERE au.RequestId = @RequestId
END