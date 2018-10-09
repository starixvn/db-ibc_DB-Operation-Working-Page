/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_User_GetAll]
AS
/*  
 Created: Raymond.Le@20180907
 Task : Get all user for assignment
 DB: bodb_OWP

 Revisions:
	20181009@Raymond.Le: new structure
*/
BEGIN
	SET NOCOUNT ON

	SELECT u.UserId
		,u.Username
		,u.Nickname
		,u.Extension
		,u.Phone
		,u.Skype
	FROM dbo.[User] AS u WITH (NOLOCK)
	WHERE u.Username IS NOT NULL

END