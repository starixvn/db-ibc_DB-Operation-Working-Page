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
	20190405@Lita.Tang: Apply for the second account only (row 133,151,172)- [Redmine: #111068]
	20190521@Leo.Vo: Add Username value - [Feature: #113765]
	20200830@Jacob: Delete unused code - [Redmine: #137757]
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

	-- edit
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