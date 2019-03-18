
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_GetUserInfoById] @UserId INT
AS
/*
Created: 20190318@Leo.Vo
Task : Get user info
DB: bodb_OWP

Revisions:
	20190318@Leo.Vo: Initial SP - [Redmine: #110322]
*/
BEGIN
	SET NOCOUNT ON

	SELECT UserId
		,FullName
		,Nickname
	FROM dbo.[User] WITH (NOLOCK)
	WHERE UserId = @UserId
END