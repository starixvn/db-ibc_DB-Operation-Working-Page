
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_GetUserInfoById] @UserId INT
AS
/*
Created: 20190318@Leo.Vo
Task : Get user info
DB: bodb_OWP

Revisions:
	20190318@Leo.Vo: Initial SP - [Redmine: #110322]
	20190521@Lita.Tang: Add Username value - [Feature: #113765]
	20190531@Leo.Vo: Refactor SP [Redmine: #114442]
*/
BEGIN
	SET NOCOUNT ON

	SELECT UserId
		,FullName
		,Nickname
		,Username
		,SectionId
	FROM dbo.[User] WITH (NOLOCK)
	WHERE UserId = @UserId
END