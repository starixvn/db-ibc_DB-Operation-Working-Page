
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_GetAllShift] @UserId INT = 0
AS
/*
Created: 20161220@Razor.Nguyen
Task : Get list of shift code
DB: bodb_OWP

Revisions:
	20180917@Kane.Le: New structure of event assignment - [Redmine: #92868]
	20190123@Leo.Vo: New schema of WS - [Redmine: #108206]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @TimezoneOffset INT = dbo.fnc_GetWorkingShiftTimezoneOffset(@UserId)

	SELECT ShiftId
		,UPPER(ShiftCode) AS ShiftCode
		,(CASE 
			WHEN ISNULL(LTRIM(RTRIM(Background)), '') = '' THEN '#ffffff'
			ELSE Background END
			) AS Background
		,(CASE 
			WHEN ISNULL(LTRIM(RTRIM(Color)), '') = '' THEN '#000000'
			ELSE Color END
			) AS Color
		,DATEADD(MINUTE, @TimezoneOffset, StartTime) AS StartTime
		,DATEADD(MINUTE, @TimezoneOffset, EndTime) AS EndTime
		,IsTimeShift
	FROM dbo.EmployeeWorkingShiftColor WITH (NOLOCK)
END;