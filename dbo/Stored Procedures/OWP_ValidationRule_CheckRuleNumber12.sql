/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber12] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(4000) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 12: Exceed trader working shift
 DB: bodb_OWP

 Revisions:
	20180727@Raymond.Le: Validate exceed trader working shift - [Redmine: #92868]
	20190124@Raymond.Le: Change ShiftCode to ShiftId - [Redmine: #108206]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 12
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@EventDate DATE
		,@FromTimePM TIME = '12:00:00'
		,@ToTimePM TIME = '23:59:59'
		-----------
		,@UserId INT
		,@Username NVARCHAR(30) = ''
		,@Bettype INT
		,@EventDateTime DATETIME
		,@idoc INT

	SELECT @RuleResultType = RuleResultType
		,@Message = MessageFormat
	FROM dbo.ValidationRule WITH (NOLOCK)
	WHERE RuleId = @RuleId

	SELECT @Passed = ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'RuleResultType'
		AND Value = 'Passed'

	CREATE TABLE #tblAssignmentUploading (
		RowNumber INT
		,ColumnName NVARCHAR(100)
		,Trader NVARCHAR(200)
		,UserId INT
		,IsValid BIT
		)

	CREATE TABLE #tblCombineInvalidTrader (
		RowNumber INT
		,ColumnName NVARCHAR(MAX)
		)

	CREATE TABLE #tblOtherTrader (
		RowNumber INT
		,Bettype INT
		,Trader NVARCHAR(200)
		,UserId INT
		,IsValid INT
		)

	CREATE TABLE #tblGroupOtherTrader (
		RowNumber INT
		,Bettype INT
		,ColumnName NVARCHAR(100)
		,Trader NVARCHAR(200)
		,UserId INT
		,IsValid INT
		)

	CREATE TABLE #tblValidTrader (
		RowNumber INT
		,UserId INT
		)

	CREATE TABLE #tblInvalidOtherTrader (
		RowNumber INT
		,ColumnName NVARCHAR(2000)
		)

	CREATE TABLE #tblUnionInvalidTrader (
		RowNumber INT
		,ColumnName NVARCHAR(2000)
		)

	-- upload
	IF LEN(@SessionId) > 0
	BEGIN
		-- Get trader of normal match (rowNum = 10, 20, 30....)
		INSERT INTO #tblAssignmentUploading (
			RowNumber
			,ColumnName
			,Trader
			,UserId
			,IsValid
			)
		SELECT DISTINCT RowNumber
			,(CASE unpvt.ColumnName
				WHEN 'TraderHDP' THEN 'Trader (HDP)'
				WHEN 'Trader1HHDP' THEN 'Trader (1H HDP)'
				WHEN 'TraderOU' THEN 'Trader (O/U)'
				WHEN 'Trader1HOU' THEN 'Trader (1H O/U)'
				WHEN 'Trader1X2' THEN 'Trader (1X2)'
				WHEN 'Trader1H1X2' THEN 'Trader (1H 1X2)'
				WHEN 'LA' THEN 'LA' END
				) AS ColumnName
			,unpvt.Trader
			,u.UserId
			,0
		FROM (
			SELECT RowNumber
				,TraderHDP
				,Trader1HHDP
				,TraderOU
				,Trader1HOU
				,Trader1X2
				,Trader1H1X2
				,LA
			FROM dbo.AssignmentUploading WITH (NOLOCK)
			WHERE SessionId = @SessionId
			) AS upload
		UNPIVOT(Trader FOR ColumnName IN (TraderHDP, Trader1HHDP, TraderOU, Trader1HOU, Trader1X2, Trader1H1X2, LA)) unpvt
			INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON unpvt.Trader = u.Nickname
			OR unpvt.Trader = u.Username
		WHERE ISNULL(unpvt.Trader, '') <> ''
			AND (RowNumber % 10) = 0
		
		UNION -- Get trader of special match (rowNum = 11, 12, 13, 14, 21, 22....)
		SELECT au.RowNumber / 10 * 10
			,(CASE au.RowNumber % 10
				WHEN 1 THEN 'Trader (15mins)'
				WHEN 2 THEN 'Trader (10mins)'
				WHEN 3 THEN 'Trader (FM)'
				WHEN 4 THEN 'Trader (AIO)' END
				) AS ColumnName
			,au.TraderHDP
			,u.UserId
			,0
		FROM dbo.AssignmentUploading AS au WITH (NOLOCK)
			INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON au.TraderHDP = u.Nickname
			OR au.TraderHDP = u.Username
		WHERE SessionId = @SessionId
			AND (RowNumber % 10) <> 0
			AND ISNULL(au.TraderHDP, '') <> ''

		-- other traders
		INSERT INTO #tblOtherTrader (
			RowNumber
			,Bettype
			,Trader
			,UserId
			,IsValid
			)
		SELECT ot.RowNumber
			,ot.Bettype
			,ot.Trader
			,u.UserId
			,0
		FROM dbo.AssignmentUploadingOtherTrader AS ot WITH (NOLOCK)
			INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON ot.Trader = u.Nickname
			OR ot.Trader = u.Username
		WHERE ISNULL(ot.Trader, '') <> ''
			AND ot.SessionId = @SessionId

		-- Get current Event Date
		SELECT TOP 1 @EventDate = (CASE 
				WHEN CAST(au.KickOffTime AS TIME) BETWEEN @FromTimePM
						AND @ToTimePM THEN au.EventDate
				ELSE DATEADD(DAY, - 1, au.EventDate) END
				)
		FROM dbo.AssignmentUploading AS au WITH (NOLOCK)
		WHERE au.SessionId = @SessionId
			AND ISDATE(au.KickOffTime) = 1

		-- Get valid trader of both main & other
		INSERT INTO #tblValidTrader (
			RowNumber
			,UserId
			)
		SELECT au.RowNumber
			,au.UserId
		FROM (
			SELECT main.RowNumber
				,main.UserId
				,DATEADD(dd, DATEDIFF(dd, 0, au.EventDate), CAST(au.KickOffTime AS DATETIME)) AS EventDateTime
			FROM #tblAssignmentUploading AS main
				INNER JOIN dbo.AssignmentUploading AS au WITH (NOLOCK) ON main.RowNumber = au.RowNumber
				AND au.SessionId = @SessionId
			WHERE ISDATE(au.KickOffTime) = 1
			
			UNION
			SELECT other.RowNumber
				,other.UserId
				,DATEADD(dd, DATEDIFF(dd, 0, au.EventDate), CAST(au.KickOffTime AS DATETIME)) AS EventDateTime
			FROM #tblOtherTrader AS other
				INNER JOIN dbo.AssignmentUploading AS au WITH (NOLOCK) ON other.RowNumber = au.RowNumber
				AND au.SessionId = @SessionId
			WHERE ISDATE(au.KickOffTime) = 1
			) AS au
		WHERE EXISTS (
				SELECT 1
				FROM dbo.EmployeeWorkingShift AS ws WITH (NOLOCK)
				WHERE ws.EmployeeId = au.UserId
					AND ws.ShiftDate IN (@EventDate, DATEADD(DAY, - 1, @EventDate), DATEADD(DAY, 1, @EventDate))
					AND (
						ws.ShiftStartTime <= au.EventDateTime
						AND ws.ShiftEndTime >= DATEADD(MINUTE, 120, au.EventDateTime)
						)
				)

		-- Update status isValid
		UPDATE main
		SET main.IsValid = 1
		FROM #tblAssignmentUploading AS main
			LEFT JOIN #tblValidTrader AS vt ON main.RowNumber = vt.RowNumber
			AND main.UserId = vt.UserId
		WHERE vt.UserId IS NOT NULL

		UPDATE other
		SET other.IsValid = 1
		FROM #tblOtherTrader AS other
			LEFT JOIN #tblValidTrader AS vt ON other.RowNumber = vt.RowNumber
			AND other.UserId = vt.UserId
		WHERE vt.UserId IS NOT NULL

		INSERT INTO #tblGroupOtherTrader (
			RowNumber
			,Bettype
			,ColumnName
			,Trader
			,UserId
			,IsValid
			)
		SELECT DISTINCT RowNumber
			,Bettype
			,(CASE Bettype
				WHEN 1 THEN 'OtherTraders (HDP)'
				WHEN 7 THEN 'OtherTraders (1H HDP)'
				WHEN 3 THEN 'OtherTraders (O/U)'
				WHEN 8 THEN 'OtherTraders (1H O/U)'
				WHEN 5 THEN 'OtherTraders (1X2)'
				WHEN 15 THEN 'OtherTraders (1H 1X2)'
				WHEN - 1002 THEN 'OtherLA' END
				) AS ColumnName
			,Trader
			,UserId
			,IsValid
		FROM #tblOtherTrader WITH (NOLOCK)
		WHERE (RowNumber % 10) = 0
		
		UNION -- Special match (rowNum = 11, 12, 13, 14, 21, 22....)
		SELECT DISTINCT RowNumber
			,Bettype
			,(CASE RowNumber % 10
				WHEN 1 THEN 'OtherTraders (15mins)'
				WHEN 2 THEN 'OtherTraders (10mins)'
				WHEN 3 THEN 'OtherTraders (FM)'
				WHEN 4 THEN 'OtherTraders (AIO)' END
				) AS ColumnName
			,Trader
			,UserId
			,IsValid
		FROM #tblOtherTrader WITH (NOLOCK)
		WHERE (RowNumber % 10) <> 0

		-- Join trader name follow bettype(ex: OtherTraders (AIO): starix2, starix3)
		INSERT INTO #tblInvalidOtherTrader (
			RowNumber
			,ColumnName
			)
		SELECT (ot1.RowNumber / 10) * 10
			,got.ColumnName + ': ' + STUFF((
					SELECT DISTINCT ', ' + ot2.Trader
					FROM #tblOtherTrader ot2
					WHERE ot2.RowNumber = ot1.RowNumber
						AND ot2.Bettype = ot1.Bettype
						AND ot2.IsValid = 0
					FOR XML PATH('')
						,TYPE
					).value('(./text())[1]', 'VARCHAR(200)'), 1, 2, '') AS ColumnName
		FROM #tblOtherTrader ot1
			INNER JOIN #tblGroupOtherTrader got ON ot1.RowNumber = got.RowNumber
			AND ot1.Bettype = got.Bettype
		WHERE ot1.IsValid = 0
		GROUP BY ot1.RowNumber
			,ot1.Bettype
			,got.ColumnName

		-- combine
		INSERT INTO #tblUnionInvalidTrader (
			RowNumber
			,ColumnName
			)
		SELECT RowNumber
			,ColumnName
		FROM #tblAssignmentUploading WITH (NOLOCK)
		WHERE IsValid = 0
		
		UNION
		SELECT RowNumber
			,ColumnName
		FROM #tblInvalidOtherTrader WITH (NOLOCK)

		INSERT INTO #tblCombineInvalidTrader (
			RowNumber
			,ColumnName
			)
		SELECT data.RowNumber
			,STUFF((
					SELECT '; ' + ColumnName
					FROM #tblUnionInvalidTrader WITH (NOLOCK)
					WHERE RowNumber = data.RowNumber
					FOR XML PATH('')
					), 1, 2, '')
		FROM (
			SELECT DISTINCT RowNumber
			FROM #tblUnionInvalidTrader WITH (NOLOCK)
			) AS data

		-- result
		SELECT @SessionId
			,upload.RowNumber
			,@RuleId AS RuleId
			,(CASE 
				WHEN trader.RowNumber IS NOT NULL THEN @RuleResultType
				ELSE @Passed END
				) AS ResultType
			,(CASE 
				WHEN trader.RowNumber IS NOT NULL THEN REPLACE(@Message, '<content>', trader.ColumnName)
				ELSE '' END
				) AS [Message]
		FROM dbo.AssignmentUploading AS upload WITH (NOLOCK)
			LEFT JOIN #tblCombineInvalidTrader AS trader WITH (NOLOCK) ON upload.RowNumber = trader.RowNumber
		WHERE upload.SessionId = @SessionId
	END
	ELSE -- edit
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @UserId = data.UserId
			,@Username = data.Username
			,@Bettype = data.Bettype
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Username NVARCHAR(30), Bettype INT, UserId INT) AS data

		EXEC sp_xml_removedocument @idoc

		SELECT @EventDateTime = om.EventDateTime
			,@EventDate = (CASE 
				WHEN CAST(om.KickOffTime AS TIME) BETWEEN @FromTimePM
						AND @ToTimePM THEN om.EventDate
				ELSE DATEADD(DAY, - 1, om.EventDate) END
				) -- this EventDate is Date in upload file, not the Event Date field
		FROM dbo.OWPMatch AS om WITH (NOLOCK)
		WHERE om.OWPMatchId = @OWPMatchId

		-- Check valid assignee
		IF @UserId IS NULL
		OR EXISTS (
				SELECT 1
				FROM dbo.EmployeeWorkingShift AS ws WITH (NOLOCK)
				WHERE ws.EmployeeId = @UserId
					AND ws.ShiftDate IN (@EventDate, DATEADD(DAY, - 1, @EventDate), DATEADD(DAY, 1, @EventDate))
					AND (
						ws.ShiftStartTime <= @EventDateTime
						AND ws.ShiftEndTime >= DATEADD(MINUTE, 120, @EventDateTime)
						)
				)
		BEGIN
			SELECT @Passed AS ResultType
				,'' AS [Message]
		END
		ELSE
		BEGIN
			SELECT @RuleResultType AS ResultType
				,REPLACE(@Message, '<content>', @Username) AS [Message]
		END
	END

	DROP TABLE #tblAssignmentUploading

	DROP TABLE #tblCombineInvalidTrader

	DROP TABLE #tblOtherTrader

	DROP TABLE #tblGroupOtherTrader

	DROP TABLE #tblInvalidOtherTrader

	DROP TABLE #tblValidTrader

	DROP TABLE #tblUnionInvalidTrader
END