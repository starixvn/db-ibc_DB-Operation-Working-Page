CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber25] @SessionId NVARCHAR(100) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(MAX) = NULL
AS
/*
 Created: 20170316@Tim.Trinh
 Task : Rule number 25: Duplicate employee name
 DB: bodb_OWP

 Revisions:
    20170407@Tim.Trinh: check match 15mins, 10mins
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 25
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@UserId INT
		,@Trader NVARCHAR(100)
		,@idoc INT

	CREATE TABLE #tblAssignmentUploading (
		RowNumber INT
		,ColumnName NVARCHAR(100)
		,Trader NVARCHAR(100)
		,IsInvalid BIT
		)
	
	CREATE TABLE #tblCombineInvalidTrader (
		RowNumber INT
		,Trader NVARCHAR(MAX)
		)

	SELECT @RuleResultType = RuleResultType
		,@Message = MessageFormat
	FROM dbo.ValidationRule WITH (NOLOCK)
	WHERE RuleId = @RuleId

	SELECT @Passed = ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'RuleResultType'
		AND Value = 'Passed'

	-- upload
	IF LEN(@SessionId) > 0
	BEGIN
		INSERT INTO #tblAssignmentUploading (
			RowNumber
			,ColumnName
			,Trader
			,IsInvalid
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
				WHEN 'LA1H' THEN 'Trader (1H LA)'
				WHEN 'Standby1HLA' THEN 'Standby (1H LA)'
				WHEN 'OtherTime1HLA' THEN 'Other Time (1H LA)'
				WHEN 'ETPK1HLA' THEN 'ET & PK (1H LA)'
				WHEN 'LA2H' THEN 'Trader (2H LA)'
				WHEN 'Standby2HLA' THEN 'Standby (2H LA)'
				WHEN 'OtherTime2HLA' THEN 'Other Time (2H LA)'
				WHEN 'ETPK2HLA' THEN 'ET & PK (2H LA)' END
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
				,LA1H
				,Standby1HLA
				,OtherTime1HLA
				,ETPK1HLA
				,LA2H
				,Standby2HLA
				,OtherTime2HLA
				,ETPK2HLA
			FROM dbo.AssignmentUploading WITH (NOLOCK)
			WHERE SessionId = @SessionId
			) AS upload
		UNPIVOT(Trader FOR ColumnName IN (  
				TraderHDP
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
				,LA1H
				,Standby1HLA
				,OtherTime1HLA
				,ETPK1HLA
				,LA2H
				,Standby2HLA
				,OtherTime2HLA
				,ETPK2HLA)) unpvt
		WHERE ISNULL(unpvt.Trader, '') <> ''
		
		INSERT INTO #tblAssignmentUploading (
			RowNumber
			,ColumnName
			,Trader
			,IsInvalid
			)
		SELECT DISTINCT RowNumber / 10 * 10 AS RowNumber
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
		SET upload.IsInvalid = 1
		FROM #tblAssignmentUploading AS upload WITH (NOLOCK)
		WHERE upload.IsInvalid = 0
			AND (
				SELECT COUNT(1)
				FROM dbo.[User] AS u WITH (NOLOCK)
				WHERE u.Username = upload.Trader
					OR u.Nickname = upload.Trader				
				) > 1

		-- combine
		INSERT INTO #tblCombineInvalidTrader (
			RowNumber
			,Trader
			)
		SELECT data.RowNumber
			,STUFF((
					SELECT DISTINCT '; ' + Trader
					FROM #tblAssignmentUploading WITH (NOLOCK)
					WHERE RowNumber = data.RowNumber
						AND IsInvalid = 1
					FOR XML PATH('')
					), 1, 2, '')
		FROM (
			SELECT DISTINCT RowNumber
			FROM #tblAssignmentUploading WITH (NOLOCK)
			WHERE IsInvalid = 1
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
				WHEN trader.RowNumber IS NOT NULL THEN REPLACE(@Message, '<content>', trader.Trader)
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

		IF (SELECT COUNT(1)
				FROM dbo.[User] AS u WITH (NOLOCK)
				WHERE u.Username = @Trader
					OR u.Nickname = @Trader) > 1
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