
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShiftTimeZone_UpdateUserSetting] @UserId INT
	,@SettingId SMALLINT
AS
/*    
 Created: 20180124@Raymond.Le
 Task : Update Working Shift TimeZone setting for user
 DB: bodb_OWP

 Revisions:
	20180124@Raymond.Le: Initial SP - [Redmine: #108206]
	20190521@Kane.Le: - Write log for Time zone setting [Redmine: #113763]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@Xml XML

	SET @StartRun = GETDATE()
	SET @Xml = (
			SELECT @UserId AS '@uid'
				,ISNULL(ou.TimeZoneSettingId, '') AS '@tzid'
			FROM [User] ou WITH (NOLOCK)
			WHERE ou.UserId = @UserId
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

	UPDATE dbo.[User]
	WITH (
			ROWLOCK
			,UPDLOCK
			)

	SET TimeZoneSettingId = @SettingId
	WHERE UserId = @UserId
	--New data
	SET @Xml = (
			SELECT @UserId AS '@uid'
				,@SettingId AS '@tzid'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @UserId
		,@SPName = 'OWP_EmployeeWorkingShiftTimeZone_UpdateUserSetting'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @UserId
		,@Data = @LogData
		,@DataOld = @LogDataOld
END