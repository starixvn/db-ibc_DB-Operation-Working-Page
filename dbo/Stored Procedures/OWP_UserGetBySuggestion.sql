/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_UserGetBySuggestion] @Keyword NVARCHAR(100)
AS
/*
 Created: 20161226@Razor.Nguyen
 Task : Get Users by suggestion.
 DB: bodb_OWP

 Revisions: 
 20180914@Kane.Le
 Task: Get Username output
*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #tblUsers (
		UserId INT
		,Username NVARCHAR(150)
		,NickName NVARCHAR(150)
		)

	INSERT INTO #tblUsers (
		UserId
		,Username
		,NickName
		)
	SELECT UserId
		,Username
		,NickName
	FROM dbo.[User] WITH (NOLOCK)
	WHERE NickName LIKE @Keyword + '%'
		OR Username LIKE @Keyword + '%'

	INSERT INTO #tblUsers (
		UserId
		,Username
		,NickName
		)
	SELECT UserId
		,Username
		,NickName
	FROM dbo.[User] WITH (NOLOCK)
	WHERE Username LIKE @Keyword + '%'
		AND UserId NOT IN (
			SELECT UserId
			FROM #tblUsers WITH (NOLOCK)
			)

	SELECT TOP 10 UserId
		,Username
		,NickName
	FROM #tblUsers WITH (NOLOCK)

	DROP TABLE #tblUsers
END