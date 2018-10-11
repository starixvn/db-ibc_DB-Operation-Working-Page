/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber25] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(4000) = NULL
AS
/*
 Created: 20170316@Tim.Trinh
 Task : Rule number 25: Duplicate employee name
 DB: bodb_OWP

 Revisions:
    20170407@Tim.Trinh: check match 15mins, 10mins
    20180621@Leo.Vo: new structure of Upload Assignment - [Redmine: #92868]
	20180725@Raymond.Le: Modify rule follow new uploading structure - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 25
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@UserId INT
		,@Username NVARCHAR(30)
		,@idoc INT

	CREATE TABLE #tblAssignmentUploading (
		RowNumber INT
		,ColumnName NVARCHAR(100)
		,Trader NVARCHAR(100)
		,IsValid BIT
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
			,1
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
				AND (RowNumber % 10) = 0
			) AS upload
		UNPIVOT(Trader FOR ColumnName IN (TraderHDP, Trader1HHDP, TraderOU, Trader1HOU, Trader1X2, Trader1H1X2, LA)) unpvt
		WHERE ISNULL(unpvt.Trader, '') <> ''

		-- 10 mins & 15 mins & FM & AIO
		INSERT INTO #tblAssignmentUploading (
			RowNumber
			,ColumnName
			,Trader
			,IsValid
			)
		SELECT DISTINCT RowNumber / 10 * 10
			,(CASE RowNumber % 10
				WHEN 1 THEN 'Trader 15mins'
				WHEN 2 THEN 'Trader 10mins'
				WHEN 3 THEN 'Trader FM'
				WHEN 4 THEN 'Trader AIO' END
				) AS ColumnName
			,TraderHDP
			,1
		FROM dbo.AssignmentUploading WITH (NOLOCK)
		WHERE SessionId = @SessionId
			AND (RowNumber % 10) <> 0
			AND ISNULL(TraderHDP, '') <> ''

		-- other traders
		INSERT INTO #tblAssignmentUploading (
			RowNumber
			,ColumnName
			,Trader
			,IsValid
			)
		SELECT DISTINCT RowNumber
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
			,1
		FROM dbo.AssignmentUploadingOtherTrader ot WITH (NOLOCK)
		WHERE ISNULL(ot.Trader, '') <> ''
			AND ot.SessionId = @SessionId
			AND (ot.RowNumber % 10) = 0
		
		UNION
		SELECT DISTINCT (ot.RowNumber / 10) * 10
			,(CASE RowNumber % 10
				WHEN 1 THEN 'OtherTraders 15mins'
				WHEN 2 THEN 'OtherTraders 10mins'
				WHEN 3 THEN 'OtherTraders (FM)'
				WHEN 4 THEN 'OtherTraders (AIO)' END
				) AS ColumnName
			,ot.Trader
			,1
		FROM dbo.AssignmentUploadingOtherTrader ot WITH (NOLOCK)
		WHERE ISNULL(ot.Trader, '') <> ''
			AND ot.SessionId = @SessionId
			AND (ot.RowNumber % 10) <> 0

		-- check trader name
		UPDATE upload
		SET upload.IsValid = 0
		FROM #tblAssignmentUploading AS upload WITH (NOLOCK)
		WHERE upload.IsValid = 1
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

		SELECT TOP 1 @Username = data.Username
		FROM OPENXML(@idoc, '/Root/Row', 1) 
		WITH (Username NVARCHAR(30)) AS data

		EXEC sp_xml_removedocument @idoc

		IF (
				SELECT COUNT(1)
				FROM dbo.[User] AS u WITH (NOLOCK)
				WHERE u.Username = @Username
					OR u.Nickname = @Username
				) > 1
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
END