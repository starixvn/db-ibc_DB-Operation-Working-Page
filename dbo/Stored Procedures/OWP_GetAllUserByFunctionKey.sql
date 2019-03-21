 /*<info serverAlias="DBPOL-NAP_UserControl" executers="bodbAdminNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_GetAllUserByFunctionKey] @FunctionKey NVARCHAR(100) = 'NotificationSettingWatcher'
AS
/*      
 Created: 20190220@Kane.Le
 Task : Working Shift Management Sync NotificationSettingPermisson
 DB: bodb_OWP      
 
 Revisions:
     20190107@Kane.Le: Init SP      [Redmine: #108723]	 
	 20190314@Kane.Le: Update Policy     [Redmine: #109560]	 

-- @Note:    
EXEC [OWP_GetAllUserByFunctionKey] @FunctionKey = N'NotificationSettingWatcher';
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @OWPSiteId INT = 99
	DECLARE @FunctionId INT

	SELECT @FunctionId = fn.FunctionId
	FROM dbo.NAP_Functions fn WITH (NOLOCK)
	WHERE SiteId = @OWPSiteId
		AND fn.FunctionKey = @FunctionKey

	SELECT fn.UserId
		,fn.FunctionId
		,fn.[Policy]		
	FROM dbo.NAP_UserFunction fn WITH (NOLOCK)
	WHERE FunctionId = @FunctionId AND fn.[Policy] > 0
END
