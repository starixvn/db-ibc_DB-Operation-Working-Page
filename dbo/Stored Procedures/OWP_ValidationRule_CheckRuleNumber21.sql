/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber21] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(2000) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 21: Invalid Spread
 DB: bodb_OWP

 Revisions:
	20180621@Leo.Vo: new structure of Upload Assignment
	20180724@Raymond.Le: Modify rule follow new uploading structure 
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 21
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@Spread VARCHAR(200)
		,@idoc INT
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@Specific15MinsNoOfCorners INT = - 5
		,@Specific15MinsTotalBooking INT = - 8
		,@FastMarket INT = - 88
		,@AllInOne INT = - 89

	CREATE TABLE #tblAssignmentUploading (
		RowNumber INT
		,ColumnName NVARCHAR(100)
		,Spread NVARCHAR(200)
		,IsValid BIT
		)

	CREATE TABLE #tblCombineInvalidSpread (
		RowNumber INT
		,ColumnName NVARCHAR(MAX)
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
			,Spread
			,IsValid
			)
		SELECT RowNumber
			,(CASE ColumnName
				WHEN 'SpreadHDP' THEN 'Spread (HDP)'
				WHEN 'Spread1HHDP' THEN 'Spread (1H HDP)'
				WHEN 'SpreadOU' THEN 'Spread (O/U)'
				WHEN 'Spread1HOU' THEN 'Spread (1H O/U)'
				WHEN 'Spread1X2' THEN 'Spread (1X2)'
				WHEN 'Spread1H1X2' THEN 'Spread (1H 1X2)'
				WHEN 'SpreadXmins' THEN 'Spread (x mins)'
				WHEN 'SpreadFM' THEN 'Spread (FM)' END
				) AS ColumnName
			,unpvt.Spread
			,0
		FROM (
			SELECT RowNumber
				,SpreadHDP
				,Spread1HHDP
				,SpreadOU
				,Spread1HOU
				,Spread1X2
				,Spread1H1X2
				,SpreadXMins
				,SpreadFM
			FROM dbo.AssignmentUploading WITH (NOLOCK)
			WHERE SessionId = @SessionId
				AND ISNULL(MinorBettypeId, 0) NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
			) AS upload
		UNPIVOT(Spread FOR ColumnName IN (SpreadHDP, Spread1HHDP, SpreadOU, Spread1HOU, Spread1X2, Spread1H1X2, SpreadXMins, SpreadFM)) unpvt

		-- check spread
		UPDATE upload
		SET upload.IsValid = 1
		FROM #tblAssignmentUploading AS upload WITH (NOLOCK)
		WHERE ISNULL(upload.Spread, '') = ''
			OR (
				ISNUMERIC(upload.Spread) = 1
				AND SIGN(upload.Spread) > 0
				)

		-- combine
		INSERT INTO #tblCombineInvalidSpread (
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
				WHEN spread.RowNumber IS NOT NULL THEN @RuleResultType
				ELSE @Passed END
				) AS ResultType
			,(CASE 
				WHEN spread.RowNumber IS NOT NULL THEN REPLACE(@Message, '<content>', spread.ColumnName)
				ELSE '' END
				) AS [Message]
		FROM dbo.AssignmentUploading AS upload WITH (NOLOCK)
			LEFT JOIN #tblCombineInvalidSpread AS spread WITH (NOLOCK) ON upload.RowNumber = spread.RowNumber
		WHERE upload.SessionId = @SessionId
	END
	ELSE -- edit
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @Spread = data.Spread
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Spread VARCHAR(200)) AS data

		EXEC sp_xml_removedocument @idoc

		IF ISNUMERIC(@Spread) = 0
		BEGIN
			SELECT @RuleResultType AS ResultType
				,@Message AS [Message]
		END
		ELSE
		BEGIN
			SELECT @Passed AS ResultType
				,'' AS [Message]
		END
	END

	DROP TABLE #tblAssignmentUploading

	DROP TABLE #tblCombineInvalidSpread
END