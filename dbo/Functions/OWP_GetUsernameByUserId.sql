/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[OWP_GetUsernameByUserId] (@userid INT)
RETURNS VARCHAR(30)
AS
/*
Created: 20170301@Tim.Trinh
Task : get Username by UserId
DB: bodb_OWP

Param's Explanation:

Revisions:
	20181009@Raymond.Le: new structure
*/
BEGIN
	DECLARE @username VARCHAR(30)

	SELECT TOP 1 @username = (CASE 
			WHEN ISNULL(Nickname, '') <> '' THEN Nickname
			ELSE Username END
			)
	FROM dbo.[User] WITH (NOLOCK)
	WHERE UserId = @userid

	RETURN @username
END