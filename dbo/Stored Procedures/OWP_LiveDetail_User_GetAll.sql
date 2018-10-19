
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
*/
BEGIN
	SET NOCOUNT ON

	SELECT u.UserId
		,u.Username
		,ISNULL(u.Nickname, u.Username) AS Nickname
		,u.Extension
		,u.Phone
		,u.Skype
	FROM dbo.[User] AS u WITH (NOLOCK)
	WHERE u.Username IS NOT NULL
END