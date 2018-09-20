-- =============================================
-- Author:		Julien
-- Create date: 19-Oct-2016
-- Description:	Get nickname from OWP. If null get username from main db
-- =============================================
CREATE FUNCTION [dbo].[OWP_UsernameGetByID]
(
	@userid int
)
RETURNS VARCHAR(30)
AS
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