/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_UserGetBySuggestion] @Keyword NVARCHAR(100)
AS
/*
 Created: 20161226@Razor.Nguyen
 Task : Get Users by suggestion.
 DB: bodb_OWP

 Revisions: 
	20180914@Kane.Le: Get Username output - [Redmine: #92868]
	20181015@Kane.Le Get Nickname as Username if NULL - [Redmine: #103202]
	20190503@Kane.Le Get IsSecondAccount - [Redmine: #111840]
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @SiteId INT
	SELECT @SiteId = SiteId
	FROM DBPOL.NAP_UserControl.dbo.NAP_Sites WITH (NOLOCK)
	WHERE SiteName = 'Operation Working Page'
		AND IsActive = 1
		AND Environment = 'LIVE'

	CREATE TABLE #tblUsers (
		UserId INT
		,Username NVARCHAR(150)
		,Nickname NVARCHAR(150)
		)

	INSERT INTO #tblUsers (
		UserId
		,Username
		,Nickname
		)
	SELECT u.UserId
		,u.Username
		,u.Nickname
	FROM dbo.[User] AS u WITH (NOLOCK)
	INNER JOIN bodb02.dbo.custInfo AS ci WITH (NOLOCK) ON u.UserId = ci.custid
	INNER JOIN DBPOL.NAP_UserControl.dbo.NAP_UserSite AS us WITH (NOLOCK) ON us.UserId = u.UserId
		AND us.SiteId = @SiteId
	WHERE u.IsSecondAccount = 0  AND  (u.Nickname LIKE @Keyword + '%'
		OR u.Username LIKE @Keyword + '%')



	SELECT TOP 10 UserId
		,Username
		,ISNULL(Nickname, Username) AS Nickname
	FROM #tblUsers WITH (NOLOCK)

	DROP TABLE #tblUsers
END