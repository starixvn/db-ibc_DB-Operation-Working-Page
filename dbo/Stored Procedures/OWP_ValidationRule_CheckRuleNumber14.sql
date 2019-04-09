/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber14] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(2000) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 14: Invalid LA name
 DB: bodb_OWP

 Revisions:
    20170427@Tim.Trinh: change Trader -> Suspender, trim value
	20180621@Leo.Vo: new structure of Upload Assignment - [Redmine: #92868]
	20190405@Lita.Tang: Apply for the second account only (row 111, 150) - [Redmine: #111068]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 14
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

	CREATE TABLE #tblOtherLA (
		RowNumber INT
		,LA NVARCHAR(200)
		,IsValid INT
		)

	CREATE TABLE #tblGroupOtherLA (
		RowNumber INT
		,ColumnName NVARCHAR(100)
		,IsValid INT
		)

	CREATE TABLE #tblInvalidOtherLA (
		RowNumber INT
		,ColumnName NVARCHAR(2000)
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
			,unpvt.ColumnName
			,unpvt.Trader
			,0
		FROM (
			SELECT RowNumber
				,LA
			FROM dbo.AssignmentUploading WITH (NOLOCK)
			WHERE SessionId = @SessionId
			) AS upload
		UNPIVOT(Trader FOR ColumnName IN (LA)) unpvt
		WHERE ISNULL(unpvt.Trader, '') <> ''

		-- check other LA
		INSERT INTO #tblOtherLA (
			RowNumber
			,LA
			,IsValid
			) (
			SELECT ot.RowNumber
			,ot.Trader
			,(
				CASE ISNULL(u.UserId, 0)
					WHEN 0
						THEN 0
					ELSE 1
					END
				) AS IsValid FROM AssignmentUploadingOtherTrader AS ot LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON ot.Trader = u.Nickname
			OR ot.Trader = u.Username WHERE ISNULL(ot.Trader, '') <> '' AND ot.SessionId = @SessionId
			AND ot.Bettype = - 1002
			AND u.IsSecondAccount = 0
			)

		INSERT INTO #tblGroupOtherLA (
			RowNumber
			,ColumnName
			,IsValid
			) (
			SELECT RowNumber
			,'OtherLA' AS ColumnName
			,Min(IsValid) FROM #tblOtherLA GROUP BY RowNumber
			)

		INSERT INTO #tblInvalidOtherLA (
			RowNumber
			,ColumnName
			)
		SELECT ol1.RowNumber
			,gol.ColumnName + ': ' + STUFF((
					SELECT DISTINCT ', ' + ol2.LA
					FROM #tblOtherLA ol2
					WHERE ol2.RowNumber = ol1.RowNumber
						AND ol2.IsValid = 0
					FOR XML PATH('')
						,TYPE
					).value('(./text())[1]', 'VARCHAR(200)'), 1, 2, '') AS ColumnName
		FROM #tblOtherLA ol1
		INNER JOIN #tblGroupOtherLA gol ON ol1.RowNumber = gol.RowNumber
		WHERE ol1.IsValid = 0
		GROUP BY ol1.RowNumber
			,gol.ColumnName

		-- check trader name
		UPDATE upload
		SET upload.IsValid = 1
		FROM #tblAssignmentUploading AS upload WITH (NOLOCK)
		INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON upload.Trader = u.Nickname
			OR upload.Trader = u.Username
		WHERE upload.IsValid = 0
		AND u.IsSecondAccount = 0

		-- combine
		CREATE TABLE #tblUnionInvalidLA (
			RowNumber INT
			,ColumnName NVARCHAR(2000)
			)

		INSERT INTO #tblUnionInvalidLA (
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
		FROM #tblInvalidOtherLA WITH (NOLOCK)

		INSERT INTO #tblCombineInvalidTrader (
			RowNumber
			,ColumnName
			)
		SELECT data.RowNumber
			,STUFF((
					SELECT '; ' + ColumnName
					FROM #tblUnionInvalidLA WITH (NOLOCK)
					WHERE RowNumber = data.RowNumber
					FOR XML PATH('')
					), 1, 2, '')
		FROM (
			SELECT DISTINCT RowNumber
			FROM #tblUnionInvalidLA WITH (NOLOCK)
			) AS data

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
		WHERE SessionId = @SessionId
	END
	ELSE -- edit
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @Trader = LTRIM(RTRIM(Trader))
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