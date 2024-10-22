
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShiftTimeZone_GetByUser] @UserId INT
AS
/*    
 Created: 20180124@Raymond.Le
 Task : Get Working Shift Timezone Setting by user
 DB: bodb_OWP

 Revisions:
	20180124@Raymond.Le: Initial SP - [Redmine: #108206]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @SelectedSettingId SMALLINT

	SELECT @SelectedSettingId = ISNULL(u.TimeZoneSettingId, dfs.SettingId)
	FROM dbo.EmployeeWorkingShiftTimeZoneSetting AS dfs WITH (NOLOCK)
		LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON u.UserId = @UserId
	WHERE dfs.IsDefault = 1

	SELECT s.SettingId
		,s.NAME
		,s.Offset
		,CASE 
			WHEN s.SettingId = @SelectedSettingId THEN 1
			ELSE 0
			END AS IsSelected
	FROM dbo.EmployeeWorkingShiftTimeZoneSetting s WITH (NOLOCK)

END