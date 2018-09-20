CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber8] @SessionId NVARCHAR(100) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(MAX) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 8: Invalid trader name
 DB: bodb_OWP

 Revisions:
    20170407@Tim.Trinh: check match 15mins, 10mins
	20180416@leo.vo: check FM, AIO
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 8
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@UserId INT
		,@Trader NVARCHAR(100) = ''
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
		,Trader NVARCHAR(100)
		,IsValid BIT
		)

	CREATE TABLE #tblCombineInvalidTrader (
		RowNumber INT
		,ColumnName NVARCHAR(MAX)
		)

	-- upload
	IF LEN(@SessionId) > 0
	BEGIN
		INSERT INTO #tblAssignmentUploading (
			RowNumber
			,ColumnName
			,Trader
			,IsValid
			)
		SELECT DISTINCT RowNumber
			,(CASE unpvt.ColumnName
				WHEN 'TraderHDP' THEN 'Trader (HDP)'
				WHEN 'StandbyHDP' THEN 'Standby (HDP)'
				WHEN 'OtherTimeHDP' THEN 'Other Time (HDP)'
				WHEN 'ETPKHDP' THEN 'ET & PK (HDP)'
				WHEN 'Trader1HHDP' THEN 'Trader (1H HDP)'
				WHEN 'Standby1HHDP' THEN 'Standby (1H HDP)'
				WHEN 'OtherTime1HHDP' THEN 'Other Time (1H HDP)'
				WHEN 'TraderOU' THEN 'Trader (O/U)'
				WHEN 'StandbyOU' THEN 'Standby (O/U)'
				WHEN 'OtherTimeOU' THEN 'Other Time  (O/U)'
				WHEN 'ETPKOU' THEN 'ET & PK (O/U)'
				WHEN 'Trader1HOU' THEN 'Trader (1H O/U)'
				WHEN 'Standby1HOU' THEN 'Standby (1H O/U)'
				WHEN 'OtherTime1HOU' THEN 'Other Time (1H O/U)'
				WHEN 'Trader1X2' THEN 'Trader (1X2)'
				WHEN 'Standby1X2' THEN 'Standby (1X2)'
				WHEN 'OtherTime1X2' THEN 'Other Time (1X2)'
				WHEN 'Trader1H1X2' THEN 'Trader (1H 1X2)'
				WHEN 'Standby1H1X2' THEN 'Standby (1H 1X2)'
				WHEN 'OtherTime1H1X2' THEN 'Other Time (1H 1X2)'
				WHEN 'FM' THEN 'FM'
				WHEN 'AIO' THEN 'AIO' END
				) AS ColumnName
			,unpvt.Trader
			,0
		FROM (
			SELECT RowNumber
				,TraderHDP
				,StandbyHDP
				,OtherTimeHDP
				,ETPKHDP
				,Trader1HHDP
				,Standby1HHDP
				,OtherTime1HHDP
				,TraderOU
				,StandbyOU
				,OtherTimeOU
				,ETPKOU
				,Trader1HOU
				,Standby1HOU
				,OtherTime1HOU
				,Trader1X2
				,Standby1X2
				,OtherTime1X2
				,Trader1H1X2
				,Standby1H1X2
				,OtherTime1H1X2
				,FM
				,AIO
			FROM dbo.AssignmentUploading WITH (NOLOCK)
			WHERE SessionId = @SessionId
			) AS upload
		UNPIVOT(Trader FOR ColumnName IN (TraderHDP, StandbyHDP, OtherTimeHDP, ETPKHDP, Trader1HHDP, Standby1HHDP, OtherTime1HHDP, TraderOU, StandbyOU, OtherTimeOU, ETPKOU, Trader1HOU, Standby1HOU, OtherTime1HOU, Trader1X2, Standby1X2, OtherTime1X2, Trader1H1X2, Standby1H1X2, OtherTime1H1X2, FM, AIO)) unpvt
		WHERE ISNULL(unpvt.Trader, '') <> ''

		INSERT INTO #tblAssignmentUploading (
			RowNumber
			,ColumnName
			,Trader
			,IsValid
			)
		SELECT DISTINCT RowNumber / 10 * 10
			,(CASE RowNumber % 10
				WHEN 1 THEN (CASE unpvt.ColumnName
						WHEN 'TraderHDP' THEN '10mins HDP'
						WHEN 'TraderOU' THEN '10mins OU' END
						)
				WHEN 2 THEN (CASE unpvt.ColumnName
						WHEN 'TraderHDP' THEN '15mins HDP'
						WHEN 'TraderOU' THEN '15mins OU' END
						) END
				) AS ColumnName
			,unpvt.Trader
			,0 AS IsValid
		FROM (
			SELECT RowNumber
				,TraderHDP
				,TraderOU
			FROM dbo.AssignmentUploading WITH (NOLOCK)
			WHERE SessionId = @SessionId
				AND (RowNumber % 10) <> 0
			) AS upload
		UNPIVOT(Trader FOR ColumnName IN (TraderHDP, TraderOU)) unpvt
		WHERE ISNULL(unpvt.Trader, '') <> ''

		-- check trader name
		UPDATE upload
		SET upload.IsValid = 1
		FROM #tblAssignmentUploading AS upload WITH (ROWLOCK)
			INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON upload.Trader = u.Nickname
			OR upload.Trader = u.Username
		WHERE upload.IsValid = 0

		-- combine
		INSERT INTO #tblCombineInvalidTrader (
			RowNumber
			,ColumnName
			)
		SELECT data.RowNumber
			,STUFF((
					SELECT '; ' + ColumnName
					FROM #tblAssignmentUploading WITH (NOLOCK)
					WHERE RowNumber = data.RowNumber
						AND IsValid = 0
					FOR XML PATH('')
					), 1, 2, '')
		FROM (
			SELECT DISTINCT RowNumber
			FROM #tblAssignmentUploading WITH (NOLOCK)
			WHERE IsValid = 0
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

		SELECT TOP 1 @Trader = Trader
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Trader NVARCHAR(100)) AS data

		EXEC sp_xml_removedocument @idoc

		SELECT @UserId = dbo.OWP_GetUserIdByUsername(@Trader)

		IF LEN(@Trader) > 0
			AND ISNULL(@UserId, 0) = 0
		BEGIN
			SELECT @RuleResultType AS ResultType
				,REPLACE(@Message, '<content>', @Trader) AS [Message]
		END
		ELSE
		BEGIN
			SELECT @Passed AS ResultType
				,'' AS [Message]
		END
	END

	DROP TABLE #tblAssignmentUploading

	DROP TABLE #tblCombineInvalidTrader
END