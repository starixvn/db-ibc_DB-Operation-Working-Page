
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_Upload] @Data XML
AS
/*      
 Created: 20180312@Leo.Vo     
 Task : Working Shift Management
 DB: bodb_OWP      
      
 Revisions:      
     20180925@Raymond: calculate shift time
	 20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	 20190314@Leo.Vo: New working shift with OT - [Redmine: #109560]
	 20190409@Kane.Le: Apply new rule StartTime >1 & StartTime <6 GMT 8 - [Redmine: #111068]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @tblWorkingShift TABLE (
		EmployeeId INT
		,ShiftId INT
		,ShiftDate DATE
		,ShiftStartTime DATETIME
		,ShiftEndTime DATETIME
		);

	INSERT INTO @tblWorkingShift (
		EmployeeId
		,ShiftId
		,ShiftDate
		)
	SELECT M.C.value('@EmployeeId', 'INT')
		,M.C.value('@ShiftId', 'INT')
		,M.C.value('@ShiftDate', 'DATE')
	FROM @Data.nodes('Data/Row') AS M(C);

	UPDATE ws
	SET ws.ShiftStartTime = DATEADD(DAY, CASE 
				WHEN DATEPART(HOUR, sc.StartTime)  BETWEEN 1 AND 6  THEN 1
				ELSE 0
				END, ws.ShiftDate + CAST(sc.StartTime AS DATETIME))
		,ws.ShiftEndTime = DATEADD(DAY, (CASE 
				WHEN sc.StartTime > sc.EndTime THEN 1
				ELSE 0 END
				) + (CASE 
				WHEN DATEPART(HOUR, sc.StartTime)  BETWEEN 1 AND 6  THEN 1
				ELSE 0 END
				), ws.ShiftDate + CAST(sc.EndTime AS DATETIME))
	FROM @tblWorkingShift AS ws
		INNER JOIN dbo.EmployeeWorkingShiftColor AS sc ON ws.ShiftId = sc.ShiftId
		AND sc.IsTimeShift = 1

	MERGE dbo.EmployeeWorkingShift AS t1
	USING (
		SELECT EmployeeId
			,ShiftId
			,ShiftDate
			,ShiftStartTime
			,ShiftEndTime
		FROM @tblWorkingShift
		) AS t2 ON t1.EmployeeId = t2.EmployeeId
			AND t1.ShiftDate = t2.ShiftDate
	WHEN MATCHED THEN
			UPDATE
			SET t1.ShiftId = t2.ShiftId
				,t1.ShiftStartTime = t2.ShiftStartTime
				,t1.ShiftEndTime = t2.ShiftEndTime
				,t1.RefShiftId = NULL
	WHEN NOT MATCHED THEN
			INSERT (
				EmployeeId
				,ShiftId
				,ShiftDate
				,ShiftStartTime
				,ShiftEndTime
				)
			VALUES (
				t2.EmployeeId
				,t2.ShiftId
				,t2.ShiftDate
				,t2.ShiftStartTime
				,t2.ShiftEndTime
				);
END;