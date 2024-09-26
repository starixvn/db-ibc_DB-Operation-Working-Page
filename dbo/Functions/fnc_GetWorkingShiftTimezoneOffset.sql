
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_GetWorkingShiftTimezoneOffset] (@UserId INT)
RETURNS INT
AS
/*
Created: 20190122@Leo.Vo
Task : get working shift timezone offset
DB: bodb_OWP

Param's Explanation:

Revisions:
	20190122@Leo.Vo: Initial SP - [Redmine: #108206]
*/
BEGIN
	DECLARE @TimeZoneSettingId INT
		,@TimezoneOffset INT

	SELECT @TimeZoneSettingId = u.TimeZoneSettingId
	FROM dbo.[User] AS u WITH (NOLOCK)
	WHERE UserId = @UserId

	IF @TimeZoneSettingId IS NULL
	BEGIN
		SELECT @TimezoneOffset = Offset
		FROM dbo.EmployeeWorkingShiftTimeZoneSetting WITH (NOLOCK)
		WHERE IsDefault = 1
	END
	ELSE
	BEGIN
		SELECT @TimezoneOffset = Offset
		FROM dbo.EmployeeWorkingShiftTimeZoneSetting WITH (NOLOCK)
		WHERE SettingId = @TimeZoneSettingId
	END

	RETURN @TimezoneOffset
END