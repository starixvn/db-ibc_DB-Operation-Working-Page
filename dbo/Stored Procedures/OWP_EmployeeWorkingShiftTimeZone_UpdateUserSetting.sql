/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShiftTimeZone_UpdateUserSetting] 
	@UserId INT
	,@SettingId SMALLINT
AS
/*    
 Created: 20180124@Raymond.Le
 Task : Update Working Shift TimeZone setting for user
 DB: bodb_OWP

 Revisions:
	20180124@Raymond.Le: Initial SP - [Redmine: #108206]
*/
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.[User] WITH (ROWLOCK, UPDLOCK)
	SET TimeZoneSettingId = @SettingId
	WHERE UserId = @UserId

END