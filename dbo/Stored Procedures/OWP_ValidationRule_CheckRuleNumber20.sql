/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber20] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(2000) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 20: Invalid Maxbet
 DB: bodb_OWP

 Revisions:
    20180621@Leo.Vo: new structure of Upload Assignment - [Redmine: #92868]
	20180724@Raymond.Le: Modify rule follow new uploading structure - [Redmine: #92868] 
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 20
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@MaxBet VARCHAR(200)
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
		,MaxBet NVARCHAR(200)
		,IsValid BIT
		)

	CREATE TABLE #tblCombineInvalidMaxBet (
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
			,MaxBet
			,IsValid
			)
		SELECT RowNumber
			,(CASE ColumnName
				WHEN 'MaxBetHDP' THEN 'Max Bet (HDP)'
				WHEN 'MaxBet1HHDP' THEN 'Max Bet (1H HDP)'
				WHEN 'MaxBetOU' THEN 'Max Bet (O/U)'
				WHEN 'MaxBet1HOU' THEN 'Max Bet (1H O/U)'
				WHEN 'MaxBet1X2' THEN 'Max Bet (1X2)'
				WHEN 'MaxBet1H1X2' THEN 'Max Bet (1H 1X2)'
				WHEN 'MaxBetXMins' THEN 'Max Bet (x mins)'
				WHEN 'MaxBetFM' THEN 'Max Bet (FM)' END
				) AS ColumnName
			,unpvt.MaxBet
			,0
		FROM (
			SELECT RowNumber
				,(CASE 
					WHEN RIGHT(LOWER(MaxBetHDP), 1) = 'k' THEN SUBSTRING(MaxBetHDP, 0, LEN(MaxBetHDP))
					ELSE MaxBetHDP END
					) AS MaxBetHDP
				,(CASE 
					WHEN RIGHT(LOWER(MaxBet1HHDP), 1) = 'k' THEN SUBSTRING(MaxBet1HHDP, 0, LEN(MaxBet1HHDP))
					ELSE MaxBet1HHDP END
					) AS MaxBet1HHDP
				,(CASE 
					WHEN RIGHT(LOWER(MaxBetOU), 1) = 'k' THEN SUBSTRING(MaxBetOU, 0, LEN(MaxBetOU))
					ELSE MaxBetOU END
					) AS MaxBetOU
				,(CASE 
					WHEN RIGHT(LOWER(MaxBet1HOU), 1) = 'k' THEN SUBSTRING(MaxBet1HOU, 0, LEN(MaxBet1HOU))
					ELSE MaxBet1HOU END
					) AS MaxBet1HOU
				,(CASE 
					WHEN RIGHT(LOWER(MaxBet1X2), 1) = 'k' THEN SUBSTRING(MaxBet1X2, 0, LEN(MaxBet1X2))
					ELSE MaxBet1X2 END
					) AS MaxBet1X2
				,(CASE 
					WHEN RIGHT(LOWER(MaxBet1H1X2), 1) = 'k' THEN SUBSTRING(MaxBet1H1X2, 0, LEN(MaxBet1H1X2))
					ELSE MaxBet1H1X2 END
					) AS MaxBet1H1X2
				,(CASE 
					WHEN RIGHT(LOWER(MaxBetXMins), 1) = 'k' THEN SUBSTRING(MaxBetXMins, 0, LEN(MaxBetXMins))
					ELSE MaxBetXMins END
					) AS MaxBetXMins
				,(CASE 
					WHEN RIGHT(LOWER(MaxBetFM), 1) = 'k' THEN SUBSTRING(MaxBetFM, 0, LEN(MaxBetFM))
					ELSE MaxBetFM END
					) AS MaxBetFM
			FROM dbo.AssignmentUploading WITH (NOLOCK)
			WHERE SessionId = @SessionId
				AND ISNULL(MinorBettypeId, 0) NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
			) AS upload
		UNPIVOT(MaxBet FOR ColumnName IN (MaxBetHDP, MaxBet1HHDP, MaxBetOU, MaxBet1HOU, MaxBet1X2, MaxBet1H1X2, MaxBetXMins, MaxBetFM)) unpvt

		-- check maxbet
		UPDATE upload
		SET upload.IsValid = 1
		FROM #tblAssignmentUploading AS upload WITH (NOLOCK)
		WHERE ISNULL(upload.MaxBet, '') = ''
			OR (
				ISNUMERIC(upload.MaxBet) = 1
				AND SIGN(upload.MaxBet) > 0
				)

		-- combine
		INSERT INTO #tblCombineInvalidMaxBet (
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
				WHEN maxbet.RowNumber IS NOT NULL THEN @RuleResultType
				ELSE @Passed END
				) AS ResultType
			,(CASE 
				WHEN maxbet.RowNumber IS NOT NULL THEN REPLACE(@Message, '<content>', maxbet.ColumnName)
				ELSE '' END
				) AS [Message]
		FROM dbo.AssignmentUploading AS upload WITH (NOLOCK)
			LEFT JOIN #tblCombineInvalidMaxBet AS maxbet WITH (NOLOCK) ON upload.RowNumber = maxbet.RowNumber
		WHERE upload.SessionId = @SessionId
	END
	ELSE -- edit
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @MaxBet = data.MaxBet
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (MaxBet VARCHAR(200)) AS data

		EXEC sp_xml_removedocument @idoc

		IF ISNUMERIC(@MaxBet) = 0
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

	DROP TABLE #tblCombineInvalidMaxBet
END