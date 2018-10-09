/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[OWP_UsernameGetByID]
(
	@userid int
)
RETURNS VARCHAR(30)
AS
/*
Created: 20161019@julien
Task : Get nickname from OWP. If null get username from main db
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: new structure
*/
BEGIN
	-- Declare the return variable here
	DECLARE @username VARCHAR(30)

	-- Add the T-SQL statements to compute the return value here
	SELECT @username = Nickname
	FROM [user] WITH (NOLOCK)
	WHERE UserId = @userid
	
	IF (@username IS NULL)
		SELECT @username = username
		FROM bodb02.dbo.Customer WITH (NOLOCK)
		WHERE custid = @userid

	-- Return the result of the function
	RETURN @username

END