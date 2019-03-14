
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShiftColorIns] @WorkingShift XML
AS
/*
Created: 20180213@Jacob
Task: Employee Working Shift Management
DB: bodb_OWP

 Revisions:
	20180920@Leo: upper working shift
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20190125@Kane.Le: Change Name to ShiftCode, Add StartTime, EndTime, IsTimeShift - [Redmine: #108206]
	20190314@Kane.Le: Distinct shiftId, shiftCode - [Redmine: #109560]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @tblEmployeeWorkingShiftColor TABLE (
		ShiftId INT
		,ShiftCode NVARCHAR(50)
		,Background VARCHAR(50)
		,Color VARCHAR(50)
		,StartTime TIME(7)
		,EndTime TIME(7)
		,IsTimeShift BIT
		);

	INSERT INTO @tblEmployeeWorkingShiftColor (
		ShiftCode
		,Background
		,Color
		,StartTime
		,EndTime
		,IsTimeShift
		)
	SELECT UPPER(t.c.value('@ShiftCode', 'NVARCHAR(50)')) AS ShiftCode
		,t.c.value('@Background', 'VARCHAR(50)') AS Background
		,t.c.value('@Color', 'VARCHAR(50)') AS Color
		,t.c.value('@StartTime', 'TIME(7)') AS StartTime
		,t.c.value('@EndTime', 'TIME(7)') AS EndTime
		,t.c.value('@IsTimeShift', 'bit') AS IsTimeShift
	FROM @WorkingShift.nodes('Data/Row') AS t(c);

	-- fill ShiftId for time shift
	UPDATE t
	SET t.ShiftId = s.ShiftId
	FROM @tblEmployeeWorkingShiftColor AS t
		INNER JOIN dbo.EmployeeWorkingShiftColor AS s WITH (NOLOCK) ON t.StartTime = s.StartTime
		AND t.EndTime = s.EndTime
		AND t.IsTimeShift = s.IsTimeShift
		AND t.IsTimeShift = 1

	-- fill ShiftId for non-time shift
	UPDATE t
	SET t.ShiftId = s.ShiftId
	FROM @tblEmployeeWorkingShiftColor AS t
		INNER JOIN dbo.EmployeeWorkingShiftColor AS s WITH (NOLOCK) ON t.ShiftCode = s.ShiftCode
		AND t.IsTimeShift = s.IsTimeShift
		AND t.IsTimeShift = 0

	DECLARE @tblNewEmployeeWorkingShiftColor TABLE (
		ShiftCode NVARCHAR(50) NOT NULL
		,ShiftId INT NOT NULL
		)

	MERGE dbo.EmployeeWorkingShiftColor AS t
	USING (
		SELECT ShiftCode
			,Background
			,Color
			,StartTime
			,EndTime
			,IsTimeShift
		FROM @tblEmployeeWorkingShiftColor
		WHERE ShiftId IS NULL
		) AS s ON 1 = 0
	WHEN NOT MATCHED THEN
			INSERT (
				ShiftCode
				,Background
				,Color
				,StartTime
				,EndTime
				,IsTimeShift
				)
			VALUES (
				s.ShiftCode
				,s.Background
				,s.Color
				,s.StartTime
				,s.EndTime
				,s.IsTimeShift
				)
	OUTPUT inserted.ShiftCode
		,inserted.ShiftId
	INTO @tblNewEmployeeWorkingShiftColor(ShiftCode, ShiftId);

	-- fill ShiftId for remaining
	UPDATE t
	SET t.ShiftId = s.ShiftId
	FROM @tblEmployeeWorkingShiftColor AS t
		INNER JOIN @tblNewEmployeeWorkingShiftColor AS s ON t.ShiftCode = s.ShiftCode
		AND t.ShiftId IS NULL

	SELECT ShiftId
		,ShiftCode
		,Background
		,Color
		,StartTime
		,EndTime
		,IsTimeShift
	FROM @tblEmployeeWorkingShiftColor
END;