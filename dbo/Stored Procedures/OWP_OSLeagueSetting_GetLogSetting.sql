
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_OSLeagueSetting_GetLogSetting]
	@LeagueSettingId INT
AS
/*      
 Created: 20220808@Johnny.Thai
 Task : Get log
 DB: bodb_OWP      
 
 Revisions:
    20220808@Johnny.Thai: Init sp - [Redmine: #175994]
*/
BEGIN
	SET NOCOUNT ON;
	DECLARE @tblOSSettingLogAction TABLE (
		ActionId INT PRIMARY KEY
	)
	INSERT INTO @tblOSSettingLogAction (ActionId)
	VALUES (123), (124)
	SELECT
		ul.LoggedDate AS ModifiedDate
		,u.Username  AS ModifiedBy
		,ul.ActionId AS [Action]
		,ul.DataOld
		,ul.Data
	FROM dbo.UserLog AS ul WITH (NOLOCK)
	INNER JOIN @tblOSSettingLogAction AS sp ON ul.ActionId = sp.ActionId
	LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON ul.CreatorId = u.UserId
	WHERE ul.ObjectId = @LeagueSettingId
END;