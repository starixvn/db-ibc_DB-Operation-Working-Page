/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber19] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(4000) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 19: Wrong priority assignment
 DB: bodb_OWP

 Revisions:
	20180621@Leo.Vo: new structure of Upload Assignment - [Redmine: #92868]
	20180724@Raymond.Le: Modify rule follow new uploading structure - [Redmine: #92868]
	20181213@Raymond.Le: Fix missing update new assignee - [Redmine: #105667]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 19
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@MaxBet20000 MONEY = 20000
		,@MaxBet21000 MONEY = 21000
		,@MaxBet60000 MONEY = 60000
		,@MaxBet61000 MONEY = 61000
		,@MaxBet150000 MONEY = 150000
		,@MaxBet151000 MONEY = 151000
		------
		,@Username NVARCHAR(30)
		,@Bettype INT
		,@UserId INT
		,@idoc INT
		,@MaxBet MONEY
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@Specific15MinsNoOfCorners INT = - 5
		,@Specific15MinsTotalBooking INT = - 8
		,@FastMarket INT = - 88
		,@AllInOne INT = - 89
		,@MainAssignment TINYINT = 1
		,@BettypeHDP INT = 1
		,@BettypeOU INT = 3
		,@Bettype1HHDP INT = 7
		,@Bettype1HOU INT = 8

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
		,TraderHDP NVARCHAR(200)
		,Trader1HHDP NVARCHAR(200)
		,TraderOU NVARCHAR(200)
		,Trader1HOU NVARCHAR(200)
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
			,TraderHDP
			,Trader1HHDP
			,TraderOU
			,Trader1HOU
			)
		SELECT RowNumber
			,CASE 
				WHEN ISNUMERIC(MaxBetHDP) = 1 THEN CAST(MaxBetHDP AS MONEY)
				ELSE NULL
				END
			,TraderHDP
			,Trader1HHDP
			,TraderOU
			,Trader1HOU
		FROM dbo.AssignmentUploading WITH (NOLOCK)
		WHERE SessionId = @SessionId
			AND ISNULL(MinorBettypeId, 0) NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)

		-- MaxBet [0-20k]
		INSERT INTO #tblWrongPriorityAssignment (
			RowNumber
			,MaxBet
			)
		SELECT upload.RowNumber
			,upload.MaxBetHDP
		FROM #tblAssignmentUploading AS upload WITH (NOLOCK)
		WHERE upload.MaxBetHDP IS NOT NULL
			AND upload.MaxBetHDP BETWEEN 0
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
			,upload.MaxBetHDP
		FROM #tblAssignmentUploading AS upload WITH (NOLOCK)
		WHERE upload.MaxBetHDP IS NOT NULL
			AND upload.MaxBetHDP BETWEEN @MaxBet21000
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
			,upload.MaxBetHDP
		FROM #tblAssignmentUploading AS upload WITH (NOLOCK)
		WHERE upload.MaxBetHDP IS NOT NULL
			AND upload.MaxBetHDP BETWEEN @MaxBet61000
				AND @MaxBet150000
			AND (
				upload.TraderHDP = upload.TraderOU
				OR upload.TraderHDP = upload.Trader1HHDP
				OR upload.TraderOU = upload.Trader1HHDP
				OR upload.Trader1HHDP <> upload.Trader1HOU
				)

		-- MaxBet [>=151k]
		INSERT INTO #tblWrongPriorityAssignment (
			RowNumber
			,MaxBet
			)
		SELECT upload.RowNumber
			,upload.MaxBetHDP
		FROM #tblAssignmentUploading AS upload WITH (NOLOCK)
		WHERE upload.MaxBetHDP IS NOT NULL
			AND upload.MaxBetHDP >= @MaxBet151000
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
			,upload.MaxBetHDP
		FROM #tblAssignmentUploading AS upload WITH (NOLOCK)
		WHERE ISNULL(upload.MaxBetHDP, '') = ''
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
				WHEN m.RowNumber IS NOT NULL THEN REPLACE(@Message, '<content>', ISNULL(m.MaxBet, ''))
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

		SELECT TOP 1 @UserId = data.UserId
			,@Bettype = data.Bettype
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Bettype INT, UserId INT) AS data

		EXEC sp_xml_removedocument @idoc

		-- Get assignmet of 4 bettype HDP, OU, 1HHDP, 1HOU
		INSERT INTO #tblAssignment (
			OWPMatchId
			,TraderHDP
			,TraderOU
			,Trader1HHDP
			,Trader1HOU
			)
		SELECT OWPMatchId
			,MAX((CASE 
					WHEN Bettype = @BettypeHDP THEN UserId
					ELSE NULL END
					)) AS TraderHDP
			,MAX((CASE 
					WHEN Bettype = @BettypeOU THEN UserId
					ELSE NULL END
					)) AS TraderOU
			,MAX((CASE 
					WHEN Bettype = @Bettype1HHDP THEN UserId
					ELSE NULL END
					)) AS Trader1HHDP
			,MAX((CASE 
					WHEN Bettype = @Bettype1HOU THEN UserId
					ELSE NULL END
					)) AS Trader1HOU
		FROM dbo.Assignment WITH (NOLOCK)
		WHERE OWPMatchId = @OWPMatchId
			AND AssignmentType = @MainAssignment
			AND Bettype IN (@BettypeHDP, @BettypeOU, @Bettype1HHDP, @Bettype1HOU)
		GROUP BY OWPMatchId

		UPDATE #tblAssignment
		SET TraderHDP = (CASE WHEN @Bettype = @BettypeHDP THEN @UserId 
							ELSE TraderHDP END)
			,TraderOU = (CASE WHEN @Bettype = @BettypeOU THEN @UserId 
							ELSE TraderOU END)
			,Trader1HHDP = (CASE WHEN @Bettype = @Bettype1HHDP THEN @UserId 
							ELSE Trader1HHDP END)
			,Trader1HOU = (CASE WHEN @Bettype = @Bettype1HOU THEN @UserId 
							ELSE Trader1HOU END)

		-- Get MaxBet HDP of current match (This match must be main match)
		SELECT @MaxBet = ms.Maxbet
		FROM dbo.MatchSetting AS ms WITH (NOLOCK)
		WHERE ms.OWPMatchId = @OWPMatchId
			AND ms.Bettype = @BettypeHDP

		IF @MaxBet IS NULL
		BEGIN
			SELECT @MaxBet = dbo.OWP_MaxBetGet(om.OWPMatchId, om.OWPLeagueId, @Bettype)
			FROM dbo.OWPMatch AS om WITH (NOLOCK)
			WHERE om.OWPMatchId = @OWPMatchId
		END

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

		-- MaxBet [>=151k]
		INSERT INTO #tblWrongPriorityAssignment (
			RowNumber
			,MaxBet
			)
		SELECT 1
			,@MaxBet
		FROM #tblAssignment WITH (NOLOCK)
		WHERE @MaxBet >= @MaxBet151000
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
		WHERE ISNULL(@MaxBet, '') = ''
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
						) THEN REPLACE(@Message, '<content>', '')
				ELSE '' END
				) AS [Message]
	END

	DROP TABLE #tblAssignment

	DROP TABLE #tblAssignmentUploading

	DROP TABLE #tblWrongPriorityAssignment

	DROP TABLE #tblCombineWrongPriorityAssignment
END