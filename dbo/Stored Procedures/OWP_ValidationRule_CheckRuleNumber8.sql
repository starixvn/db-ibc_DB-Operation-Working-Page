/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber8] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(4000) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 8: Invalid trader name, LA name
 DB: bodb_OWP

 Revisions:
    20170407@Tim.Trinh: check match 15mins, 10mins
	20180416@leo.vo: check FM, AIO
	20180621@Leo.Vo: new structure of Upload Assignment
	20180719@Raymond.Le: Modify rule follow new uploading structure, combine rule 8 + 14 
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 8
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@UserId INT
		,@Username NVARCHAR(30) = ''
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

	CREATE TABLE #tblOtherTrader (
		RowNumber INT
		,Bettype INT
		,Trader NVARCHAR(200)
		,IsValid INT
		)

	CREATE TABLE #tblGroupOtherTrader (
		RowNumber INT
		,ColumnName NVARCHAR(100)
		,Bettype INT
		,IsValid INT
		)

	CREATE TABLE #tblInvalidOtherTrader (
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
			,IsValid
			)
		SELECT DISTINCT RowNumber
			,(
				CASE unpvt.ColumnName
					WHEN 'TraderHDP'
						THEN 'Trader (HDP)'
					WHEN 'Trader1HHDP'
						THEN 'Trader (1H HDP)'
					WHEN 'TraderOU'
						THEN 'Trader (O/U)'
					WHEN 'Trader1HOU'
						THEN 'Trader (1H O/U)'
					WHEN 'Trader1X2'
						THEN 'Trader (1X2)'
					WHEN 'Trader1H1X2'
						THEN 'Trader (1H 1X2)'
					WHEN 'LA'
						THEN 'LA'
					END
				) AS ColumnName
			,unpvt.Trader
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
		UNPIVOT(Trader FOR ColumnName IN (
					TraderHDP
					,Trader1HHDP
					,TraderOU
					,Trader1HOU
					,Trader1X2
					,Trader1H1X2
					,LA
					)) unpvt
		WHERE ISNULL(unpvt.Trader, '') <> ''
			AND (RowNumber % 10) = 0

		-- Get trader of special match (rowNum = 11, 12, 13, 14, 21, 22....)
		INSERT INTO #tblAssignmentUploading (
			RowNumber
			,ColumnName
			,Trader
			,IsValid
			)
		SELECT RowNumber / 10 * 10
			,(
				CASE RowNumber % 10
					WHEN 1
						THEN 'Trader (15mins)'
					WHEN 2
						THEN 'Trader (10mins)'
					WHEN 3
						THEN 'Trader (FM)'
					WHEN 4
						THEN 'Trader (AIO)'
					END
				) AS ColumnName
			,TraderHDP
			,0
		FROM dbo.AssignmentUploading WITH (NOLOCK)
		WHERE SessionId = @SessionId
			AND (RowNumber % 10) <> 0
			AND ISNULL(TraderHDP, '') <> ''

		-- check trader name
		UPDATE upload
		SET upload.IsValid = 1
		FROM #tblAssignmentUploading AS upload WITH (ROWLOCK)
		INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON upload.Trader = u.Nickname
			OR upload.Trader = u.Username
		WHERE upload.IsValid = 0

		-- other traders
		INSERT INTO #tblOtherTrader (
			RowNumber
			,Bettype
			,Trader
			,IsValid
			)
		SELECT ot.RowNumber
			,ot.Bettype
			,ot.Trader
			,(
				CASE ISNULL(u.UserId, 0)
					WHEN 0
						THEN 0
					ELSE 1
					END
				) AS IsValid
		FROM dbo.AssignmentUploadingOtherTrader AS ot WITH (NOLOCK)
		LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON ot.Trader = u.Nickname
			OR ot.Trader = u.Username
		WHERE ISNULL(ot.Trader, '') <> ''
			AND ot.SessionId = @SessionId

		INSERT INTO #tblGroupOtherTrader (
			RowNumber
			,ColumnName
			,Bettype
			,IsValid
			)
		SELECT RowNumber
			,(
				CASE Bettype
					WHEN 1
						THEN 'OtherTraders (HDP)'
					WHEN 7
						THEN 'OtherTraders (1H HDP)'
					WHEN 3
						THEN 'OtherTraders (O/U)'
					WHEN 8
						THEN 'OtherTraders (1H O/U)'
					WHEN 5
						THEN 'OtherTraders (1X2)'
					WHEN 15
						THEN 'OtherTraders (1H 1X2)'
					WHEN - 1002
						THEN 'OtherLA'
					END
				) AS ColumnName
			,Bettype
			,Min(IsValid)
		FROM #tblOtherTrader
		WHERE (RowNumber % 10) = 0
		GROUP BY RowNumber
			,Bettype
		
		UNION -- Special match (rowNum = 11, 12, 13, 14, 21, 22....)
		SELECT RowNumber
			,(
				CASE RowNumber % 10
					WHEN 1
						THEN 'OtherTraders (15mins)'
					WHEN 2
						THEN 'OtherTraders (10mins)'
					WHEN 3
						THEN 'OtherTraders (FM)'
					WHEN 4
						THEN 'OtherTraders (AIO)'
					END
				) AS ColumnName
			,Bettype
			,Min(IsValid)
		FROM #tblOtherTrader
		WHERE (RowNumber % 10) <> 0
		GROUP BY RowNumber
			,Bettype

		-- Join trader name follow bettype(ex: OtherTraders (AIO): starix2, starix3)
		INSERT INTO #tblInvalidOtherTrader (
			RowNumber
			,ColumnName
			)
		SELECT (ot1.RowNumber/10)*10
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
		CREATE TABLE #tblUnionInvalidTrader (
			RowNumber INT
			,ColumnName NVARCHAR(2000)
			)

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

		DROP TABLE #tblUnionInvalidTrader

		-- result
		SELECT @SessionId
			,upload.RowNumber
			,@RuleId AS RuleId
			,(
				CASE 
					WHEN trader.RowNumber IS NOT NULL
						THEN @RuleResultType
					ELSE @Passed
					END
				) AS ResultType
			,(
				CASE 
					WHEN trader.RowNumber IS NOT NULL
						THEN REPLACE(@Message, '<content>', trader.ColumnName)
					ELSE ''
					END
				) AS [Message]
		FROM dbo.AssignmentUploading AS upload WITH (NOLOCK)
		LEFT JOIN #tblCombineInvalidTrader AS trader WITH (NOLOCK) ON upload.RowNumber = trader.RowNumber
		WHERE upload.SessionId = @SessionId
	END
	ELSE -- edit
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @Username = data.Username					
		FROM OPENXML(@idoc, '/Root/Row', 1) 
		WITH (Username NVARCHAR(30)) AS data

		EXEC sp_xml_removedocument @idoc

		SELECT @UserId = dbo.OWP_GetUserIdByUsername(@Username)

		IF LEN(@Username) > 0
			AND ISNULL(@UserId, 0) = 0
		BEGIN
			SELECT @RuleResultType AS ResultType
				,REPLACE(@Message, '<content>', @Username) AS [Message]
		END
		ELSE
		BEGIN
			SELECT @Passed AS ResultType
				,'' AS [Message]
		END
	END

	DROP TABLE #tblAssignmentUploading

	DROP TABLE #tblCombineInvalidTrader

	DROP TABLE #tblOtherTrader

	DROP TABLE #tblGroupOtherTrader

	DROP TABLE #tblInvalidOtherTrader
END