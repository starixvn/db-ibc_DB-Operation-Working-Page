CREATE PROCEDURE [dbo].[OWP_UserGetBySuggestion] @Keyword NVARCHAR(100)
AS
/*
 Created: 20161226@Razor.Nguyen
 Task : Get Users by suggestion.
 DB: bodb_OWP

 Revisions: 
*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #tblUsers (
		UserId INT
		,Username NVARCHAR(150)
		)

	INSERT INTO #tblUsers (
		UserId
		,Username
		)
	SELECT UserId
		,Nickname
	FROM dbo.[User] WITH (NOLOCK)
	WHERE NickName LIKE @Keyword + '%'

	INSERT INTO #tblUsers (
		UserId
		,Username
		)
	SELECT UserId
		,Username
	FROM dbo.[User] WITH (NOLOCK)
	WHERE Username LIKE @Keyword + '%'
		AND UserId NOT IN (
			SELECT UserId
			FROM #tblUsers WITH (NOLOCK)
			)

	SELECT TOP 10 UserId
		,Username
	FROM #tblUsers WITH (NOLOCK)

	DROP TABLE #tblUsers
END