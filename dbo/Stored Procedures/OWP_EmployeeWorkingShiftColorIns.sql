
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShiftColorIns] @WorkingShift XML = NULL
	,@ShiftIds VARCHAR(MAX) = NULL OUTPUT
AS
/*
Created: 20180213@Jacob
Task: Employee Working Shift Management
DB: bodb_OWP

 Revisions:
	20180920@Leo: upper working shift
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20190125@Kane.Le: Change Name to ShiftCode, Add StartTime, EndTime, IsTimeShift - [Redmine: #108206]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @TempTable TABLE (
		ShiftCode NVARCHAR(50)
		,Background VARCHAR(50)
		,Color VARCHAR(50)
		,StartTime TIME
		,EndTime TIME
		,IsTimeShift BIT
		);

	INSERT INTO @TempTable (
		ShiftCode
		,Background
		,Color
		,StartTime
		,EndTime
		,IsTimeShift
		)
	SELECT UPPER(t.c.value('@ShiftCode', 'NVARCHAR(50)')) AS ShiftCode
		,t.c.value('@Background', 'VARCHAR(20)') AS Background
		,t.c.value('@Color', 'VARCHAR(20)') AS Color
		,CAST(t.c.value('@StartTime', 'time') AS TIME) AS StartTime
		,CAST(t.c.value('@EndTime', 'time') AS TIME) AS EndTime
		,t.c.value('@IsTimeShift', 'bit') AS IsTimeShift
	FROM @WorkingShift.nodes('Data/Row') AS t(c);

	INSERT INTO dbo.EmployeeWorkingShiftColor (
		ShiftCode
		,Background
		,Color
		,StartTime
		,EndTime
		,IsTimeShift
		)
	SELECT t.ShiftCode
		,t.Background
		,t.Color
		,t.StartTime
		,t.EndTime
		,t.IsTimeShift
	FROM @TempTable AS t
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.EmployeeWorkingShiftColor AS w WITH (NOLOCK)
			WHERE w.ShiftCode = t.ShiftCode
			);

	DECLARE @val VARCHAR(MAX)

	SELECT @val = COALESCE(@val + ', ' + CAST(wsc.ShiftId AS NVARCHAR(5)), CAST(wsc.ShiftId AS NVARCHAR(5)))
	FROM dbo.[EmployeeWorkingShiftColor] wsc WITH (NOLOCK)
	JOIN @TempTable t ON wsc.ShiftCode = t.ShiftCode
	ORDER BY wsc.ShiftCode

	SET @ShiftIds = @val
END;