CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber19] @SessionId NVARCHAR(100) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(MAX) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 19: Wrong priority assignment
 DB: bodb_OWP

 Revisions:
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 19
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Bettype INT
		,@idoc INT
		,@MaxBet MONEY
		,@Message NVARCHAR(200)
		,@MaxBet20000 MONEY = 20000
		,@MaxBet21000 MONEY = 21000
		,@MaxBet60000 MONEY = 60000
		,@MaxBet61000 MONEY = 61000
		,@MaxBet150000 MONEY = 150000
		,@MaxBet151000 MONEY = 151000
		,@MaxBet400000 MONEY = 400000
	DECLARE @Handicap TINYINT = 1
		,@Assignee TINYINT = 1

	SELECT @RuleResultType = RuleResultType
		,@Message = MessageFormat
	FROM dbo.ValidationRule WITH (NOLOCK)
	WHERE RuleId = @RuleId

	SELECT @Passed = ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'RuleResultType'
		AND Value = 'Passed'

	CREATE TABLE #tblAssignment (
		OWPMatchId INT
		,TraderHDP INT NULL
		,TraderOU INT NULL
		,Trader1HHDP INT NULL
		,Trader1HOU INT NULL
		)

	CREATE TABLE #tblAssignmentUploading (
		RowNumber INT
		,MaxBetHDP MONEY
		)

	CREATE TABLE #tblWrongPriorityAssignment (
		RowNumber INT
		,MaxBet MONEY
		)

	CREATE TABLE #tblCombineWrongPriorityAssignment (
		RowNumber INT
		,MaxBet NVARCHAR(MAX)
		)

	-- upload
	IF LEN(@SessionId) > 0
	BEGIN
		INSERT INTO #tblAssignmentUploading (
			RowNumber
			,MaxBetHDP
			)
		SELECT RowNumber
			,CAST(MaxBetHDP AS MONEY)
		FROM dbo.AssignmentUploading WITH (NOLOCK)
		WHERE SessionId = @SessionId
			AND ISNUMERIC(MaxBetHDP) = 1

		-- MaxBet [0-20k]
		INSERT INTO #tblWrongPriorityAssignment (
			RowNumber
			,MaxBet
			)
		SELECT upload.RowNumber
			,upload1.MaxBetHDP
		FROM dbo.AssignmentUploading AS upload WITH (NOLOCK)
			INNER JOIN #tblAssignmentUploading AS upload1 WITH (NOLOCK) ON upload.RowNumber = upload1.RowNumber
		WHERE SessionId = @SessionId
			AND upload1.MaxBetHDP BETWEEN 0
				AND @MaxBet20000
			AND (
				upload.TraderHDP <> upload.Trader1HHDP
				OR upload.TraderHDP <> upload.TraderOU
				OR upload.TraderHDP <> upload.Trader1HOU
				)

		-- MaxBet [21k-60k]
		INSERT INTO #tblWrongPriorityAssignment (
			RowNumber
			,MaxBet
			)
		SELECT upload.RowNumber
			,upload1.MaxBetHDP
		FROM dbo.AssignmentUploading AS upload WITH (NOLOCK)
			INNER JOIN #tblAssignmentUploading AS upload1 WITH (NOLOCK) ON upload.RowNumber = upload1.RowNumber
		WHERE SessionId = @SessionId
			AND upload1.MaxBetHDP BETWEEN @MaxBet21000
				AND @MaxBet60000
			AND (
				upload.TraderHDP = upload.TraderOU
				OR upload.TraderHDP = upload.Trader1HOU
				OR upload.TraderHDP <> upload.Trader1HHDP
				OR upload.TraderOU <> upload.Trader1HOU
				)

		-- MaxBet [61k-150k]
		INSERT INTO #tblWrongPriorityAssignment (
			RowNumber
			,MaxBet
			)
		SELECT upload.RowNumber
			,upload1.MaxBetHDP
		FROM dbo.AssignmentUploading AS upload WITH (NOLOCK)
			INNER JOIN #tblAssignmentUploading AS upload1 WITH (NOLOCK) ON upload.RowNumber = upload1.RowNumber
		WHERE SessionId = @SessionId
			AND upload1.MaxBetHDP BETWEEN @MaxBet61000
				AND @MaxBet150000
			AND (
				upload.TraderHDP = upload.TraderOU
				OR upload.TraderHDP = upload.Trader1HHDP
				OR upload.TraderOU = upload.Trader1HHDP
				OR upload.Trader1HHDP <> upload.Trader1HOU
				)

		-- MaxBet [151k-400k]
		INSERT INTO #tblWrongPriorityAssignment (
			RowNumber
			,MaxBet
			)
		SELECT upload.RowNumber
			,upload1.MaxBetHDP
		FROM dbo.AssignmentUploading AS upload WITH (NOLOCK)
			INNER JOIN #tblAssignmentUploading AS upload1 WITH (NOLOCK) ON upload.RowNumber = upload1.RowNumber
		WHERE SessionId = @SessionId
			AND upload1.MaxBetHDP BETWEEN @MaxBet151000
				AND @MaxBet400000
			AND (
				upload.TraderHDP = upload.TraderOU
				OR upload.TraderHDP = upload.Trader1HHDP
				OR upload.TraderHDP = upload.Trader1HOU
				OR upload.TraderOU = upload.Trader1HHDP
				OR upload.TraderOU = upload.Trader1HOU
				OR upload.Trader1HHDP = upload.Trader1HOU
				)

		-- without HDP MaxBet
		INSERT INTO #tblWrongPriorityAssignment (
			RowNumber
			,MaxBet
			)
		SELECT upload.RowNumber
			,upload1.MaxBetHDP
		FROM dbo.AssignmentUploading AS upload WITH (NOLOCK)
			INNER JOIN #tblAssignmentUploading AS upload1 WITH (NOLOCK) ON upload.RowNumber = upload1.RowNumber
		WHERE SessionId = @SessionId
			AND upload1.MaxBetHDP NOT BETWEEN 0
				AND @MaxBet20000
			AND upload1.MaxBetHDP NOT BETWEEN @MaxBet21000
				AND @MaxBet60000
			AND upload1.MaxBetHDP NOT BETWEEN @MaxBet61000
				AND @MaxBet150000
			AND upload1.MaxBetHDP NOT BETWEEN @MaxBet151000
				AND @MaxBet400000
			AND (
				(
					ISNULL(upload.TraderHDP, '') <> ''
					AND ISNULL(upload.TraderOU, '') <> ''
					AND upload.TraderHDP = upload.TraderOU
					)
				OR (
					ISNULL(upload.TraderHDP, '') <> ''
					AND ISNULL(upload.Trader1HOU, '') <> ''
					AND upload.TraderHDP = upload.Trader1HOU
					)
				OR (
					ISNULL(upload.TraderOU, '') <> ''
					AND ISNULL(upload.Trader1HHDP, '') <> ''
					AND upload.TraderOU = upload.Trader1HHDP
					)
				)

		-- combine
		INSERT INTO #tblCombineWrongPriorityAssignment
		SELECT data.RowNumber
			,STUFF((
					SELECT DISTINCT '; ' + CAST(MaxBet AS NVARCHAR(50))
					FROM #tblWrongPriorityAssignment WITH (NOLOCK)
					WHERE RowNumber = data.RowNumber
					FOR XML PATH('')
					), 1, 2, '')
		FROM (
			SELECT DISTINCT RowNumber
			FROM #tblWrongPriorityAssignment WITH (NOLOCK)
			) AS data

		-- result
		SELECT @SessionId
			,upload.RowNumber
			,@RuleId AS RuleId
			,(CASE 
				WHEN m.RowNumber IS NOT NULL THEN @RuleResultType
				ELSE @Passed END
				) AS ResultType
			,(CASE 
				WHEN m.RowNumber IS NOT NULL THEN REPLACE(@Message, '<content>', m.MaxBet)
				ELSE '' END
				) AS [Message]
		FROM dbo.AssignmentUploading AS upload WITH (NOLOCK)
			LEFT JOIN #tblCombineWrongPriorityAssignment AS m WITH (NOLOCK) ON upload.RowNumber = m.RowNumber
		WHERE upload.SessionId = @SessionId
	END
	ELSE -- edit
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @MaxBet = data.MaxBet
			,@Bettype = data.Bettype
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (MaxBet MONEY, Bettype INT) AS data

		EXEC sp_xml_removedocument @idoc

		IF @Bettype = @Handicap
		BEGIN
			INSERT INTO #tblAssignment (
				OWPMatchId
				,TraderHDP
				,TraderOU
				,Trader1HHDP
				,Trader1HOU
				)
			SELECT OWPMatchId
				,MAX((CASE 
						WHEN Bettype = 1 THEN UserId
						ELSE NULL END
						)) AS TraderHDP
				,MAX((CASE 
						WHEN Bettype = 3 THEN UserId
						ELSE NULL END
						)) AS TraderOU
				,MAX((CASE 
						WHEN Bettype = 7 THEN UserId
						ELSE NULL END
						)) AS Trader1HHDP
				,MAX((CASE 
						WHEN Bettype = 8 THEN UserId
						ELSE NULL END
						)) AS Trader1HOU
			FROM dbo.Assignment WITH (NOLOCK)
			WHERE OWPMatchId = @OWPMatchId
				AND AssignmentType = @Assignee
				AND Bettype IN (1, 3, 7, 8)
			GROUP BY OWPMatchId

			-- MaxBet [0-20k]
			INSERT INTO #tblWrongPriorityAssignment (
				RowNumber
				,MaxBet
				)
			SELECT 1
				,@MaxBet
			FROM #tblAssignment WITH (NOLOCK)
			WHERE @MaxBet BETWEEN 0
					AND @MaxBet20000
				AND (
					TraderHDP <> Trader1HHDP
					OR TraderHDP <> TraderOU
					OR TraderHDP <> Trader1HOU
					)

			-- MaxBet [21k-60k]
			INSERT INTO #tblWrongPriorityAssignment (
				RowNumber
				,MaxBet
				)
			SELECT 1
				,@MaxBet
			FROM #tblAssignment WITH (NOLOCK)
			WHERE @MaxBet BETWEEN @MaxBet21000
					AND @MaxBet60000
				AND (
					TraderHDP = TraderOU
					OR TraderHDP = Trader1HOU
					OR TraderHDP <> Trader1HHDP
					OR TraderOU <> Trader1HOU
					)

			-- MaxBet [61k-150k]
			INSERT INTO #tblWrongPriorityAssignment (
				RowNumber
				,MaxBet
				)
			SELECT 1
				,@MaxBet
			FROM #tblAssignment WITH (NOLOCK)
			WHERE @MaxBet BETWEEN @MaxBet61000
					AND @MaxBet150000
				AND (
					TraderHDP = TraderOU
					OR TraderHDP = Trader1HHDP
					OR TraderOU = Trader1HHDP
					OR Trader1HHDP <> Trader1HOU
					)

			-- MaxBet [151k-400k]
			INSERT INTO #tblWrongPriorityAssignment (
				RowNumber
				,MaxBet
				)
			SELECT 1
				,@MaxBet
			FROM #tblAssignment WITH (NOLOCK)
			WHERE @MaxBet BETWEEN @MaxBet151000
					AND @MaxBet400000
				AND (
					TraderHDP = TraderOU
					OR TraderHDP = Trader1HHDP
					OR TraderHDP = Trader1HOU
					OR TraderOU = Trader1HHDP
					OR TraderOU = Trader1HOU
					OR Trader1HHDP = Trader1HOU
					)

			-- without HDP MaxBet
			INSERT INTO #tblWrongPriorityAssignment (
				RowNumber
				,MaxBet
				)
			SELECT 1
				,@MaxBet
			FROM #tblAssignment WITH (NOLOCK)
			WHERE @MaxBet NOT BETWEEN 0
					AND @MaxBet20000
				AND @MaxBet NOT BETWEEN @MaxBet21000
					AND @MaxBet60000
				AND @MaxBet NOT BETWEEN @MaxBet61000
					AND @MaxBet150000
				AND @MaxBet NOT BETWEEN @MaxBet151000
					AND @MaxBet400000
				AND (
					(
						ISNULL(TraderHDP, '') <> ''
						AND ISNULL(TraderOU, '') <> ''
						AND TraderHDP = TraderOU
						)
					OR (
						ISNULL(TraderHDP, '') <> ''
						AND ISNULL(Trader1HOU, '') <> ''
						AND TraderHDP = Trader1HOU
						)
					OR (
						ISNULL(TraderOU, '') <> ''
						AND ISNULL(Trader1HHDP, '') <> ''
						AND TraderOU = Trader1HHDP
						)
					)

			-- result
			SELECT (CASE 
					WHEN EXISTS (
							SELECT 1
							FROM #tblWrongPriorityAssignment WITH (NOLOCK)
							) THEN @RuleResultType
					ELSE @Passed END
					) AS ResultType
				,(CASE 
					WHEN EXISTS (
							SELECT 1
							FROM #tblWrongPriorityAssignment WITH (NOLOCK)
							) THEN REPLACE(@Message, '<content>', STUFF((
									SELECT DISTINCT '; ' + CAST(MaxBet AS NVARCHAR(50))
									FROM #tblWrongPriorityAssignment WITH (NOLOCK)
									WHERE RowNumber = 1
									FOR XML PATH('')
									), 1, 2, ''))
					ELSE '' END
					) AS [Message]
		END
		ELSE
		BEGIN
			SELECT @Passed AS ResultType
				,'' AS [Message]
		END
	END

	DROP TABLE #tblAssignment

	DROP TABLE #tblAssignmentUploading

	DROP TABLE #tblWrongPriorityAssignment

	DROP TABLE #tblCombineWrongPriorityAssignment
END