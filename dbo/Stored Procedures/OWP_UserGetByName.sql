/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_UserGetByName] @Name NVARCHAR(100)
AS
/*
Created: 20160922@John.Ngo
Task : Get CustId By Name
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: new structure
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @UserId INT = NULL

	SELECT @UserId = dbo.OWP_GetUserIdByUsername(@Name)

	SELECT [UserId]
		,dbo.OWP_GetUsernameByUserId(@UserId) AS Username
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