
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

	SELECT
		ul.LoggedDate AS ModifiedDate
		,u.Username  AS ModifiedBy
		,ul.ActionId AS [Action]
		,ul.DataOld
		,ul.Data
	FROM dbo.UserLog AS ul WITH (NOLOCK)
	LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON ul.CreatorId = u.UserId
	WHERE ul.ObjectId = @LeagueSettingId
END;