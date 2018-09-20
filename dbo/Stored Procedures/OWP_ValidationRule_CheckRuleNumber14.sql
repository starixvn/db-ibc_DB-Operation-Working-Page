CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber14] @SessionId NVARCHAR(100) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(MAX) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 14: Invalid LA name
 DB: bodb_OWP

 Revisions:
    20170427@Tim.Trinh: change Trader -> Suspender, trim value
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
				WHEN 'LA1H' THEN 'Suspender (1H LA)'
				WHEN 'Standby1HLA' THEN 'Standby (1H LA)'
				WHEN 'OtherTime1HLA' THEN 'Other Time (1H LA)'
				WHEN 'ETPK1HLA' THEN 'ET & PK (1H LA)'
				WHEN 'LA2H' THEN 'Suspender (2H LA)'
				WHEN 'Standby2HLA' THEN 'Standby (2H LA)'
				WHEN 'OtherTime2HLA' THEN 'Other Time (2H LA)'
				WHEN 'ETPK2HLA' THEN 'ET & PK (2H LA)' END
				) AS ColumnName
			,unpvt.Trader
			,0
		FROM (
			SELECT RowNumber
				,LTRIM(RTRIM(LA1H)) AS LA1H
				,LTRIM(RTRIM(Standby1HLA)) AS Standby1HLA
				,LTRIM(RTRIM(OtherTime1HLA)) AS OtherTime1HLA
				,LTRIM(RTRIM(ETPK1HLA)) AS ETPK1HLA
				,LTRIM(RTRIM(LA2H)) AS LA2H
				,LTRIM(RTRIM(Standby2HLA)) AS Standby2HLA
				,LTRIM(RTRIM(OtherTime2HLA)) AS OtherTime2HLA
				,LTRIM(RTRIM(ETPK2HLA)) AS ETPK2HLA
			FROM dbo.AssignmentUploading WITH (NOLOCK)
			WHERE SessionId = @SessionId
			) AS upload
		UNPIVOT(Trader FOR ColumnName IN (LA1H, Standby1HLA, OtherTime1HLA, ETPK1HLA, LA2H, Standby2HLA, OtherTime2HLA, ETPK2HLA)) unpvt
		WHERE ISNULL(unpvt.Trader, '') <> ''

		-- check trader name
		UPDATE upload
		SET upload.IsValid = 1
		FROM #tblAssignmentUploading AS upload WITH (NOLOCK)
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