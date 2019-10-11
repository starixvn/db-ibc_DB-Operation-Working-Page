
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_GetAllShift] @UserId INT = 0
	,@TimezoneOffset INT = NULL
AS
/*
Created: 20161220@Razor.Nguyen
Task : Get list of shift code
DB: bodb_OWP

Revisions:
	20180917@Kane.Le: New structure of event assignment - [Redmine: #92868]
	20190123@Leo.Vo: New schema of WS - [Redmine: #108206]
	20190401@Kane.Le: Add Timezone GMT+7 To Iframe Weekly WS - [Redmine: #111068]
	20191002@Kane.Le: Add Extension ((REAL), (SPECIAL))  = '' - [Redmine: #121272]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @Offset INT = 0;

	IF (@TimezoneOffset IS NULL)
		SELECT @Offset = dbo.fnc_GetWorkingShiftTimezoneOffset(@UserId)
	ELSE
		SELECT @Offset = @TimezoneOffset

	SELECT ShiftId
		,UPPER(ShiftCode) AS ShiftCode
		,(
			CASE 
				WHEN ISNULL(LTRIM(RTRIM(Background)), '') = ''
					THEN '#ffffff'
				ELSE Background
				END
			) AS Background
		,(
			CASE 
				WHEN ISNULL(LTRIM(RTRIM(Color)), '') = ''
					THEN '#000000'
				ELSE Color
				END
			) AS Color
		,DATEADD(MINUTE, @Offset, StartTime) AS StartTime
		,DATEADD(MINUTE, @Offset, EndTime) AS EndTime
		,IsTimeShift
		,Extension
	FROM dbo.EmployeeWorkingShiftColor AS emp WITH (NOLOCK)
	WHERE (
		IsTimeShift = 1
		AND StartTime IS NOT NULL
		AND EndTime IS NOT NULL
		)
	OR (
		IsTimeShift = 0
		AND ShiftCode IS NOT NULL
		)
END;