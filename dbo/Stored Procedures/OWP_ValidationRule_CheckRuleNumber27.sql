CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber27] @SessionId NVARCHAR(100) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(MAX) = NULL
AS
/*
 Created: 20170724@Tim.Trinh
 Task : Rule number 27: Wrong assignment for special bettypes
 DB: bodb_OWP

 Revisions:
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 27
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@Trader NVARCHAR(100)
		,@IsCancelled BIT = 0
		,@idoc INT
		,@str_Live NVARCHAR(15) = 'Live'
		,@str_Cancel NVARCHAR(15) = 'Cancel'
		,@str_Postponed NVARCHAR(15) = 'Postponed'
		,@str_Suspended NVARCHAR(15) = 'Suspended'

	CREATE TABLE #tblParentMatch (
		RowNumber INT
		,MatchId NVARCHAR(2000)
		,MatchStatus NVARCHAR(15)

	)

	CREATE TABLE #tblParentMatchExisted (
		RowNumber INT
		,MatchId NVARCHAR(2000)
		,MatchStatus NVARCHAR(15)

	)

	CREATE TABLE #tblMinorMatchDifferent (
		RowNumber INT
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

		-- Get parent match status From existed match in system
		INSERT INTO #tblParentMatchExisted (
			RowNumber
			,MatchId
			,MatchStatus
		)
		SELECT 
			au.RowNumber
			,om.OWPMatchId
			,au.MatchStatus
		FROM [dbo].[OWPMatch] AS om WITH (NOLOCK)
		LEFT JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
		LEFT JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
		LEFT JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON om.OWPLeagueId = league.OWPLeagueId
		INNER JOIN dbo.AssignmentUploading AS au WITH (NOLOCK) 
			ON (au.League = league.OWPLeagueName
				AND au.Home = home.OWPTeamName 
				AND au.Away = away.OWPTeamName 
				AND au.EventDate = om.EventDate)
		WHERE au.SessionId = @SessionId
		AND au.MatchStatus IN (@str_Cancel, @str_Postponed, @str_Suspended)
		AND ISNULL(au.ParentMatchId, '') = ''
		AND ISNULL(au.ParentRowNumber, '') = ''

		--Parent match in assignment upload ( existed match + new match)
		INSERT INTO #tblParentMatch (
			RowNumber
			,MatchId
			,MatchStatus
		)
		SELECT DISTINCT 
			au.RowNumber
			,au.MatchId
			,au.MatchStatus
		FROM dbo.AssignmentUploading AS au WITH (NOLOCK)
		WHERE au.SessionId = @SessionId 			
			AND au.MatchStatus IN (@str_Cancel, @str_Postponed, @str_Suspended)
			AND ISNULL(au.ParentMatchId, '') = ''
			AND ISNULL(au.ParentRowNumber, '') = ''

		UPDATE pm
		SET pm.MatchId = me.MatchId
		FROM #tblParentMatch AS pm 
		INNER JOIN #tblParentMatchExisted AS me ON pm.RowNumber = me.RowNumber

		-- get minor match status <> parent match status
		INSERT INTO #tblMinorMatchDifferent (
			RowNumber
		)			
		SELECT DISTINCT
			au.RowNumber
		FROM dbo.AssignmentUploading AS au WITH (NOLOCK)
			LEFT JOIN #tblParentMatch AS pm ON (au.ParentRowNumber = pm.RowNumber 
												OR au.ParentMatchId = pm.MatchId)
		WHERE au.SessionId = @SessionId
			AND au.MinorBettypeId NOT IN (-1, -2, -5, -8)
			AND pm.RowNumber IS NOT NULL
			AND pm.MatchStatus <> au.MatchStatus
			
		-- result
		SELECT @SessionId
			,upload.RowNumber
			,@RuleId AS RuleId
			,(CASE 
				WHEN mm.RowNumber IS NOT NULL THEN @RuleResultType
				ELSE @Passed END
				) AS ResultType
			,(CASE 
				WHEN mm.RowNumber IS NOT NULL THEN @Message
				ELSE '' END
				) AS [Message]
		FROM dbo.AssignmentUploading AS upload WITH (NOLOCK)
			LEFT JOIN #tblMinorMatchDifferent AS mm WITH (NOLOCK) ON upload.RowNumber = mm.RowNumber
		WHERE upload.SessionId = @SessionId
	END
	ELSE -- edit
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @Trader = Trader
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Trader NVARCHAR(100)) AS data

		EXEC sp_xml_removedocument @idoc
		
		SELECT @IsCancelled = info.IsCancelled
		FROM dbo.OWPMatch AS m WITH (NOLOCK)
		INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON m.OWPMatchId = info.OWPMatchId
		INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON m.OWPMatchId = minor.ParentMatchId
		WHERE minor.MinorMatchId = @OWPMatchId

		IF @IsCancelled = 1 AND @Trader <> ''
		BEGIN
			SELECT @RuleResultType AS ResultType
				,REPLACE(@Message, '<content>', '') AS [Message]
		END
		ELSE
		BEGIN
			SELECT @Passed AS ResultType
				,'' AS [Message]
		END
	END

	DROP TABLE #tblParentMatch

	DROP TABLE #tblParentMatchExisted

	DROP TABLE #tblMinorMatchDifferent
END