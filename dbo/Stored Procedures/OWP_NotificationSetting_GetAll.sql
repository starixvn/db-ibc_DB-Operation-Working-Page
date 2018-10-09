/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_NotificationSetting_GetAll]
AS
/*          
 Created: 20180925@Kane.Le
 Task : Get All NotificationSetting
 DB: bodb_OWP_Test          
          
 Revisions:
	20181009@Raymond.Le: new structure     
         
*/
BEGIN
	SET NOCOUNT ON

	SELECT NotificationSettingId
		,NAME
		,Code
		,IsWatcher
	FROM [dbo].[NotificationSetting] WITH (NOLOCK)
END