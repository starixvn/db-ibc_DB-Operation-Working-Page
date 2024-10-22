
/*<info serverAlias="DBOWP-bodb_OWP" selecters="wsv_owp" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_GetAllAssigneeOfMatch] (
	@OWPMatchId INT)
RETURNS @User TABLE (UserId INT NOT NULL)
AS
/*
Created: Kane.Le@20190307
Task: Get assignee to send message
DB: bodb_OWP

Param's Explanation:
Revisions:
	20190307@Kane.Le: Initial SP - [Redmine: #109560]
*/
BEGIN
	DECLARE @MainMatchId INT = @OWPMatchId

	SELECT @MainMatchId = ParentMatchId
	FROM dbo.MinorMatch WITH (NOLOCK)
	WHERE MinorMatchId = @OWPMatchId

	INSERT INTO @User
	SELECT DISTINCT a.UserId
	FROM dbo.Assignment AS a WITH (NOLOCK)
		INNER JOIN (
		SELECT OWPMatchId
		FROM dbo.OWPMatch WITH (NOLOCK)
		WHERE OWPMatchId = @MainMatchId
		
		UNION
		SELECT MinorMatchId AS OWPMatchId
		FROM dbo.MinorMatch WITH (NOLOCK)
		WHERE ParentMatchId = @MainMatchId
		) AS m ON a.OWPMatchId = m.OWPMatchId
	WHERE a.UserId IS NOT NULL

	RETURN
END