
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_User_GetAll]
AS
/*  
 Created: Raymond.Le@20180907
 Task : Get all user for assignment
 DB: bodb_OWP

 Revisions:
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20181015@Kane.Le Get Nickname as Username if NULL - [Redmine: #103202]
	20190326@Kane.Le Get Only Active Users - [Redmine: #103202]
	20190405@Kane.Le Get the second account column (row 42) - [Redmine: #111068]
	20190503@Kane.Le Get IsSecondAccount - [Redmine: #111840]
	20190521@Leo.Vo: Add Username value - [Feature: #113765]
	20190704@Leo.Vo: Change message template - [Feature: #115459]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @SiteId INT

	SELECT @SiteId = SiteId
	FROM DBPOL.NAP_UserControl.dbo.NAP_Sites WITH (NOLOCK)
	WHERE SiteName = 'Operation Working Page'
		AND IsActive = 1
		AND Environment = 'LIVE'

	CREATE TABLE #tblFinalUserId (UserId INT)

	SELECT u.UserId
		,u.Username
		,u.Nickname
		,u.Extension
		,u.Phone
		,u.Skype
		,u.IsSecondAccount
	FROM dbo.[User] AS u WITH (NOLOCK)
	INNER JOIN bodb02.dbo.custInfo AS ci WITH (NOLOCK) ON u.UserId = ci.custid
	INNER JOIN DBPOL.NAP_UserControl.dbo.NAP_UserSite AS us WITH (NOLOCK) ON us.UserId = u.UserId
		AND us.SiteId = @SiteId
	WHERE ci.closed = 0
			AND ci.reject = 0
			AND ci.[Enabled] = 1
			AND us.IsActive = 1
	ORDER BY u.Username
END