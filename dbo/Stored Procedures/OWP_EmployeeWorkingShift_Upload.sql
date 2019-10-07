
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_Upload] @ActorId INT
	,@Data XML
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
	 20190520@Leo.Vo: Write log - [Redmine: #113763]
	 20191002@Kane.Le: Add Extension ((REAL), (SPECIAL))  = '' - [Redmine: #121272]
*/
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #tblUploadWorkingShift (
		[Action] VARCHAR(10)
		,EmployeeId INT
		,ShiftDate DATE
		,OldShiftId INT
		,NewShiftId INT
		,OldShiftStartTime DATETIME
		,NewShiftStartTime DATETIME
		,OldShiftEndTime DATETIME
		,NewShiftEndTime DATETIME
		,OldRefShiftId INT
		,NewRefShiftId INT
		)

	CREATE TABLE #tblUserLog (
		UserId INT
		,OldLogData NVARCHAR(MAX)
		,LogData NVARCHAR(MAX)
		)

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@ActionId INT

	SET @StartRun = GETDATE()

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
	SET ws.ShiftStartTime = (
			SELECT st.ShiftStartTime
			FROM dbo.fnc_GetShiftTime(ws.ShiftDate, ws.ShiftId) AS st
			)
		,ws.ShiftEndTime = (
			SELECT st.ShiftEndTime
			FROM dbo.fnc_GetShiftTime(ws.ShiftDate, ws.ShiftId) AS st
			)
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
		) AS t2
		ON t1.EmployeeId = t2.EmployeeId
			AND t1.ShiftDate = t2.ShiftDate
	WHEN MATCHED
		THEN
			UPDATE
			SET t1.ShiftId = t2.ShiftId
				,t1.ShiftStartTime = t2.ShiftStartTime
				,t1.ShiftEndTime = t2.ShiftEndTime
				,t1.RefShiftId = NULL
	WHEN NOT MATCHED
		THEN
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
				)
	OUTPUT $ACTION -- value is 'INSERT' OR 'UPDATE'
		,INSERTED.EmployeeId
		,INSERTED.ShiftDate
		,DELETED.ShiftId
		,INSERTED.ShiftId
		,DELETED.ShiftStartTime
		,INSERTED.ShiftStartTime
		,DELETED.ShiftEndTime
		,INSERTED.ShiftEndTime
		,DELETED.RefShiftId
		,INSERTED.RefShiftId
	INTO #tblUploadWorkingShift([Action], EmployeeId, ShiftDate, OldShiftId, NewShiftId, OldShiftStartTime, NewShiftStartTime, OldShiftEndTime, NewShiftEndTime, OldRefShiftId, NewRefShiftId);

	-- write log
	INSERT INTO #tblUserLog (UserId)
	SELECT DISTINCT EmployeeId
	FROM #tblUploadWorkingShift

	UPDATE ul
	SET OldLogData = REPLACE(CONVERT(NVARCHAR(MAX), (
					SELECT s.EmployeeId AS '@eid'
						,s.ShiftDate AS '@sd'
						,s.OldShiftId AS '@sid'
						,s.OldShiftStartTime AS '@sst'
						,s.OldShiftEndTime AS '@set'
						,s.OldRefShiftId AS '@rsid'
					FROM #tblUploadWorkingShift AS s
					WHERE ul.UserId = s.EmployeeId
					ORDER BY s.ShiftDate ASC
					FOR XML PATH('z')
						,ROOT('r')
					)), '" />', '"/"')
		,LogData = REPLACE(CONVERT(NVARCHAR(MAX), (
					SELECT s.EmployeeId AS '@eid'
						,s.ShiftDate AS '@sd'
						,s.NewShiftId AS '@sid'
						,s.NewShiftStartTime AS '@sst'
						,s.NewShiftEndTime AS '@set'
						,s.NewRefShiftId AS '@rsid'
					FROM #tblUploadWorkingShift AS s
					WHERE ul.UserId = s.EmployeeId
					ORDER BY s.ShiftDate ASC
					FOR XML PATH('z')
						,ROOT('r')
					)), '" />', '"/"')
	FROM #tblUserLog AS ul

	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	SELECT @ActionId = ActionId
	FROM dbo.LogAction WITH (NOLOCK)
	WHERE SPName = 'OWP_EmployeeWorkingShift_Upload'

	INSERT INTO dbo.UserLog (
		CreatorId
		,LoggedDate
		,ObjectId
		,ActionId
		,Duration
		,Data
		,DataOld
		)
	SELECT @ActorId
		,@StartRun
		,UserId
		,@ActionId
		,@Duration
		,LogData
		,OldLogData
	FROM #tblUserLog

	DROP TABLE #tblUploadWorkingShift

	DROP TABLE #tblUserLog
END;