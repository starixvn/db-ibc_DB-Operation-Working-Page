
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[OWP_GetUserIdByUsername] (@username VARCHAR(30))
RETURNS INT
AS
/*
Created: 20170301@Tim.Trinh
Task : get UserId by Username
DB: bodb_OWP

Param's Explanation:

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20190521@Leo.Vo: Add Username value - [Feature: #113765]
*/
BEGIN
	DECLARE @userid INT

	SELECT TOP (1) @userid = UserId
	FROM (
		SELECT UserId
		FROM dbo.[User] WITH (NOLOCK)
		WHERE Username = @username
		
		UNION ALL
		SELECT UserId
		FROM dbo.[User] WITH (NOLOCK)
		WHERE Nickname = @username
		) AS tbl

	RETURN @userid
END