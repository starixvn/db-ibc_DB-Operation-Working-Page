/*
	Created: Raymond.Le
	Date: 2019-02-25
	Task: [Redmine: #109560]
	DB: bodb_OWP
*/
--------------------------------
-- 2. Update data
--------------------------------
USE bodb_OWP

UPDATE es WITH (ROWLOCK, UPDLOCK)
SET es.ShiftEndTime = CASE 
		WHEN (ec.EndTime < StartTime) THEN DATEADD(DAY, 1, CAST(es.ShiftStartTime AS DATE)) + CAST(ec.EndTime AS DATETIME)
		ELSE CAST(es.ShiftStartTime AS DATE) + CAST(ec.EndTime AS DATETIME)
		END
FROM dbo.EmployeeWorkingShift AS es
	INNER JOIN dbo.EmployeeWorkingShiftColor AS ec WITH (NOLOCK) ON es.ShiftId = ec.ShiftId
WHERE ec.IsTimeShift = 1
GO

