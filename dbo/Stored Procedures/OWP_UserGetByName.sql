/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_UserGetByName] @Name NVARCHAR(100)
AS
/*
Created: 20160922@John.Ngo
Task : Get CustId By Name
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20190521@Leo.Vo: Add Username value - [Feature: #113765]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @UserId INT = NULL

	SELECT @UserId = dbo.OWP_GetUserIdByUsername(@Name)

	SELECT [UserId]
		,[Username]
		,[Nickname]
		,[EmployeeId]
		,[Skype]
		,[DepartmentId]
		,[SectionId]
		,[Extension]
		,[Phone]
		,[Email]
		,[LocationCode]
	FROM dbo.[User] WITH (NOLOCK)
	WHERE UserId = @UserId
END