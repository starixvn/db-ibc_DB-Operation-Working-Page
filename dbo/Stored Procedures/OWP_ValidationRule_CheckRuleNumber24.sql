/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber24] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(2000) = NULL
AS
/*
 Created: 20170310@Tim.Trinh
 Task : Rule number 24: Duplicate matches on the file
 DB: bodb_OWP

 Revisions:
    20180621@Leo.Vo: new structure of Upload Assignment - [Redmine: #92868]
	20180724@Raymond.Le: Modify rule follow new uploading structure - [Redmine: #92868]
	20200204@Kane.Le: Prevent duplicate by League/Home/Away- [Redmine: #127800]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 24
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

	CREATE TABLE #tblCombineDuplicateMatch (
		RowNumber INT
		,RowNumbers VARCHAR(MAX)
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
		INSERT INTO #tblCombineDuplicateMatch (
			RowNumber
			,RowNumbers
			)
		SELECT data.RowNumber
			,STUFF((
					SELECT DISTINCT '; ' + CAST(RowNumber / 10 AS VARCHAR(50))
					FROM dbo.AssignmentUploading WITH (NOLOCK)
					WHERE SessionId = @SessionId
						AND RowNumber <> data.RowNumber
						-- AND EventDate = data.EventDate
						AND League = data.League
						AND Home = data.Home
						AND Away = data.Away
						AND ISNULL(MinorBettypeId, 0) NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
						AND ISNULL(data.MinorBettypeId, 0) NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
					FOR XML PATH('')
					), 1, 2, '')
		FROM (
			SELECT RowNumber
				,EventDate
				,League
				,Home
				,Away
				,MinorBettypeId
			FROM dbo.AssignmentUploading WITH (NOLOCK)
			WHERE SessionId = @SessionId
			) AS data

		-- result
		SELECT @SessionId
			,RowNumber
			,@RuleId AS RuleId
			,(CASE 
				WHEN ISNULL(RowNumbers, '') <> '' THEN @RuleResultType
				ELSE @Passed END
				) AS ResultType
			,(CASE 
				WHEN ISNULL(RowNumbers, '') <> '' THEN REPLACE(@Message, '<content>', RowNumbers)
				ELSE '' END
				) AS [Message]
		FROM #tblCombineDuplicateMatch WITH (NOLOCK)
	END
	ELSE -- edit
	BEGIN
		SELECT @Passed AS ResultType
			,'' AS [Message]
	END

	DROP TABLE #tblCombineDuplicateMatch
END