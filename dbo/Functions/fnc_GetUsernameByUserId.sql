
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_GetUsernameByUserId] (@UserId INT)
RETURNS VARCHAR(30)
AS
/*
Created: 20181012@Leo.Vo
Task : get Username by UserId
DB: bodb_OWP

Param's Explanation:

Revisions:
	20181012@Leo.Vo: Notify assignee - [Redmine: #102867]
	20190521@Lita.Tang: Add Username value - [Feature: #113765]
*/
BEGIN
	DECLARE @Username VARCHAR(30)

	SELECT @Username = Username
	FROM dbo.[User] WITH (NOLOCK)
	WHERE UserId = @UserId

	RETURN @Username
END