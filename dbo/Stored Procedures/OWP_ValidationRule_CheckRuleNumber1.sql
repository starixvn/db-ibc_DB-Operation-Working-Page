CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber1] @SessionId NVARCHAR(100) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(MAX) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 1: MatchID is valid but not match to date, league, home and away info.
 DB: bodb_OWP

 Revisions:
    20170407@Tim.Trinh: remove check data in bodb02
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 1
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@IsViolated INT = 0
		,@idoc INT

	CREATE TABLE #tblAssignmentUploading (
		RowNumber INT
		,OWPMatchId INT NULL
		,owpEventDate DATE NULL
		,League NVARCHAR(2000)
		,Home NVARCHAR(200)
		,Away NVARCHAR(200)
		,IsViolated BIT
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
			,OWPMatchId
			,owpEventDate
			,League
			,Home
			,Away
			,IsViolated
			)
		SELECT RowNumber
			,(CASE 
				WHEN ISNUMERIC(MatchId) = 1 THEN CAST(MatchId AS INT)
				ELSE NULL END
				) OWPMatchId
			,(CASE 
				WHEN ISDATE(KickOffTime) = 1 THEN DATEADD(dd, DATEDIFF(dd, 0, EventDate), CAST(KickOffTime AS DATETIME))
				ELSE NULL END
				) AS owpEventDate
			,League
			,Home
			,Away
			,(CASE 
				WHEN ISNULL(MatchId, '') = ''
					OR ISNUMERIC(MatchId) = 1 THEN 0
				ELSE 1 END
				) IsViolated
		FROM dbo.AssignmentUploading WITH (NOLOCK)
		WHERE SessionId = @SessionId

		-- update IsViolated		
		UPDATE tbl
		SET tbl.IsViolated = 1
		FROM #tblAssignmentUploading AS tbl WITH (ROWLOCK, UPDLOCK)
			LEFT JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON tbl.OWPMatchId = m.OWPMatchId
			LEFT JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON m.OWPLeagueId = league.OWPLeagueId
			LEFT JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON m.OWPHomeId = home.OWPTeamId
			LEFT JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON m.OWPAwayId = away.OWPTeamId
		WHERE tbl.OWPMatchId IS NOT NULL
			AND tbl.IsViolated = 0
			AND (
				m.EventDate IS NULL
				OR CAST(m.EventDate AS DATE) <> tbl.owpEventDate
				OR ISNULL(league.OWPLeagueName, '') <> tbl.League
				OR ISNULL(home.OWPTeamName, '') <> tbl.Home
				OR ISNULL(away.OWPTeamName, '') <> tbl.Away
				)

		-- result
		SELECT @SessionId
			,RowNumber
			,@RuleId AS RuleId
			,(CASE 
				WHEN IsViolated = 1 THEN @RuleResultType
				ELSE @Passed END
				) AS ResultType
			,(CASE 
				WHEN IsViolated = 1 THEN @Message
				ELSE '' END
				) AS [Message]
		FROM #tblAssignmentUploading WITH (NOLOCK)
	END
	ELSE -- edit
	BEGIN
		SELECT @Passed AS ResultType
			,'' AS [Message]
	END

	DROP TABLE #tblAssignmentUploading
END