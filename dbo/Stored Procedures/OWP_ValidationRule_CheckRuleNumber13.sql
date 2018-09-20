CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber13] @SessionId NVARCHAR(100) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(MAX) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 13: 2nd trading 5 matches/day in month
 DB: bodb_OWP

 Revisions:
    20170407@Tim.Trinh: remove check data in bodb02
	20180417@leo.vo: add FM, AIO
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 13
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(MAX)
		,@MaxMatchTradingPerDay TINYINT
		,@UserId INT
		,@Trader NVARCHAR(100)
		,@owpEventDate DATE
		,@Timeline TIME = '12:00:00'
		,@idoc INT
	-- assignment type
	DECLARE @Assignee TINYINT = 1

	CREATE TABLE #tblAssignmentUploading (
		RowNumber INT
		,OWPMatchId INT NULL
		,owpEventDate DATE
		,League NVARCHAR(2000)
		,Home NVARCHAR(200)
		,Away NVARCHAR(200)
		,UserId INT
		,Trader NVARCHAR(100)
		,MinorBettypeId INT NULL
		,ParentMatchId INT NULL
		,ParentRowNumber INT NULL
		)

	CREATE TABLE #tblAssignmentInfo (
		OWPMatchId INT
		,owpEventDate DATE
		,UserId INT
		,MinorBettypeId INT NULL
		,MinorMatchId INT
		,ParentMatchId INT NULL
		)

	CREATE TABLE #tblCountMatchTrading (
		UserId INT
		,owpEventDate DATE
		,Total INT
		)

	CREATE TABLE #tblTrade5MatchPerDay (
		UserId INT
		,owpEventDate DATE
		)

	CREATE TABLE #tbl2Trade5MatchPerMonth (
		RowNumber INT
		,Trader NVARCHAR(100)
		)

	CREATE TABLE #tblCombine2Trade5MatchPerMonth (
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

	SELECT @MaxMatchTradingPerDay = Value
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'MaxMatchTradingPerDay'

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
			,Trader
			,MinorBettypeId
			,ParentMatchId
			,ParentRowNumber
			)
		SELECT DISTINCT RowNumber
			,OWPMatchId
			,owpEventDate
			,League
			,Home
			,Away
			,unpvt.Trader
			,MinorBettypeId
			,ParentMatchId
			,ParentRowNumber
		FROM (
			SELECT RowNumber
				,(CASE 
					WHEN ISNUMERIC(MatchId) = 1 THEN CAST(MatchId AS INT)
					ELSE NULL END
					) AS OWPMatchId
				,(CASE 
					WHEN ISDATE(KickOffTime) = 1 THEN DATEADD(dd, DATEDIFF(dd, 0, EventDate), CAST(KickOffTime AS DATETIME))
					ELSE NULL END
					) AS owpEventDate
				,League
				,Home
				,Away
				,MinorBettypeId
				,ParentMatchId
				,ParentRowNumber
				,TraderHDP
				,Trader1HHDP
				,TraderOU
				,Trader1HOU
				,Trader1X2
				,Trader1H1X2
				,FM
				,AIO
			FROM dbo.AssignmentUploading WITH (NOLOCK)
			WHERE SessionId = @SessionId
			) AS upload
		UNPIVOT(Trader FOR ColumnName IN (TraderHDP, Trader1HHDP, TraderOU, Trader1HOU, Trader1X2, Trader1H1X2, FM, AIO)) unpvt
		WHERE ISNULL(unpvt.Trader, '') <> ''


		-- clean trader
		DELETE upload
		FROM #tblAssignmentUploading AS upload WITH (UPDLOCK)
			LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON upload.Trader = u.Username
			OR upload.Trader = u.Nickname
		WHERE u.UserId IS NULL

		-- update UserId
		UPDATE upload
		SET upload.UserId = u.UserId
		FROM #tblAssignmentUploading AS upload WITH (ROWLOCK)
			INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON upload.Trader = u.Nickname
			OR upload.Trader = u.Username

		-- get assignment info
		INSERT INTO #tblAssignmentInfo (
			OWPMatchId
			,owpEventDate
			,UserId
			,MinorBettypeId
			,MinorMatchId
			,ParentMatchId
			)
		SELECT DISTINCT om.OWPMatchId
			,om.EventDate
			,a.UserId
			,minor.MinorBettypeId
			,minor.MinorMatchId
			,minor.ParentMatchId
		FROM dbo.OWPMatch AS om WITH (NOLOCK)
			INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON om.OWPLeagueId = league.OWPLeagueId
			INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
			INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
			INNER JOIN dbo.Assignment AS a WITH (NOLOCK) ON om.OWPMatchId = a.OWPMatchId
			INNER JOIN #tblAssignmentUploading AS upload WITH (NOLOCK) ON a.UserId = upload.UserId
			LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON om.OWPMatchId = minor.MinorMatchId
		WHERE upload.owpEventDate IS NOT NULL
			AND a.AssignmentType = @Assignee
			AND (
				(
					CAST(om.EventDate AS DATE) = CAST(upload.owpEventDate AS DATE)
					AND om.KickOffTime >= @Timeline
					)
				OR (
					CAST(om.EventDate AS DATE) = CAST(DATEADD(dd, 1, upload.owpEventDate) AS DATE)
					AND om.KickOffTime < @Timeline
					)
				)
			AND (
				DATEADD(dd, DATEDIFF(dd, 0, om.EventDate), CAST(om.KickOffTime AS DATETIME)) <> upload.owpEventDate
				OR league.OWPLeagueName <> upload.League
				OR home.OWPTeamName <> upload.Home
				OR away.OWPTeamName <> upload.Away
				)

		-- calculate
		UPDATE assignment
		SET assignment.ParentMatchId = assignment.OWPMatchId
		FROM #tblAssignmentUploading AS assignment WITH (ROWLOCK)
		WHERE assignment.OWPMatchId IS NOT NULL
			AND assignment.ParentMatchId IS NULL
			AND assignment.MinorBettypeId IS NULL

		UPDATE assignment
		SET assignment.ParentRowNumber = assignment.RowNumber
		FROM #tblAssignmentUploading AS assignment WITH (ROWLOCK)
		WHERE assignment.OWPMatchId IS NULL
			AND assignment.ParentRowNumber IS NULL
			AND assignment.MinorBettypeId IS NULL

		UPDATE assignment
		SET assignment.ParentMatchId = assignment.OWPMatchId
		FROM #tblAssignmentInfo AS assignment WITH (ROWLOCK)
		WHERE assignment.MinorBettypeId IS NULL

		INSERT INTO #tblCountMatchTrading (
			UserId
			,owpEventDate
			,Total
			)
		SELECT data.UserId
			,data.owpEventDate
			,COUNT(1)
		FROM (
			SELECT RowNumber
				,owpEventDate
				,UserId
			FROM #tblAssignmentUploading WITH (NOLOCK)
			WHERE MinorBettypeId IS NULL
			GROUP BY RowNumber
				,owpEventDate
				,UserId
			) AS data
		GROUP BY data.owpEventDate
			,data.UserId

		INSERT INTO #tblCountMatchTrading (
			UserId
			,owpEventDate
			,Total
			)
		SELECT data.UserId
			,data.owpEventDate
			,COUNT(1)
		FROM (
			SELECT ParentMatchId
				,owpEventDate
				,UserId
			FROM #tblAssignmentUploading WITH (NOLOCK)
			WHERE MinorBettypeId IS NOT NULL
				AND ParentMatchId IS NOT NULL
			GROUP BY ParentMatchId
				,owpEventDate
				,UserId
			) AS data
		GROUP BY data.owpEventDate
			,data.UserId

		INSERT INTO #tblCountMatchTrading (
			UserId
			,owpEventDate
			,Total
			)
		SELECT data.UserId
			,data.owpEventDate
			,COUNT(1)
		FROM (
			SELECT ParentRowNumber
				,owpEventDate
				,UserId
			FROM #tblAssignmentUploading WITH (NOLOCK)
			WHERE MinorBettypeId IS NOT NULL
				AND ParentRowNumber IS NOT NULL
				AND ParentMatchId IS NULL
			GROUP BY ParentRowNumber
				,owpEventDate
				,UserId
			) AS data
		GROUP BY data.owpEventDate
			,data.UserId

		INSERT INTO #tblCountMatchTrading (
			UserId
			,owpEventDate
			,Total
			)
		SELECT data.UserId
			,data.owpEventDate
			,COUNT(1)
		FROM (
			SELECT ParentMatchId
				,owpEventDate
				,UserId
			FROM #tblAssignmentInfo WITH (NOLOCK)
			GROUP BY ParentMatchId
				,owpEventDate
				,UserId
			) AS data
		GROUP BY data.UserId
			,data.owpEventDate

		-- get trade 5 matches/day
		INSERT INTO #tblTrade5MatchPerDay (
			UserId
			,owpEventDate
			)
		SELECT UserId
			,owpEventDate
		FROM #tblCountMatchTrading WITH (NOLOCK)
		GROUP BY UserId
			,owpEventDate
		HAVING SUM(Total) >= @MaxMatchTradingPerDay

		INSERT INTO #tblTrade5MatchPerDay (
			UserId
			,owpEventDate
			)
		SELECT t.UserId
			,[Date]
		FROM dbo.Trade5MatchPerDay AS t WITH (NOLOCK)
			INNER JOIN #tblCountMatchTrading AS t1 WITH (NOLOCK) ON t.UserId = t1.UserId
		WHERE MONTH(t.[Date]) = MONTH(t1.owpEventDate)
			AND YEAR(t.[Date]) = YEAR(t1.owpEventDate)
			AND t.[Date] NOT IN (
				SELECT DISTINCT owpEventDate
				FROM #tblCountMatchTrading WITH (NOLOCK)
				)

		-- get 2nd trading 5 matches/day
		INSERT INTO #tbl2Trade5MatchPerMonth (
			RowNumber
			,Trader
			)
		SELECT RowNumber
			,Trader
		FROM #tblAssignmentUploading AS upload WITH (NOLOCK)
		WHERE upload.UserId IN (
				SELECT UserId
				FROM #tblTrade5MatchPerDay WITH (NOLOCK)
				GROUP BY UserId
					,MONTH(owpEventDate)
					,YEAR(owpEventDate)
				HAVING COUNT(1) >= 2
				)

		-- combine
		INSERT INTO #tblCombine2Trade5MatchPerMonth (
			RowNumber
			,Trader
			)
		SELECT data.RowNumber
			,STUFF((
					SELECT '; ' + Trader
					FROM #tbl2Trade5MatchPerMonth WITH (NOLOCK)
					WHERE RowNumber = data.RowNumber
					FOR XML PATH('')
					), 1, 2, '')
		FROM (
			SELECT DISTINCT RowNumber
			FROM #tbl2Trade5MatchPerMonth WITH (NOLOCK)
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
			LEFT JOIN #tblCombine2Trade5MatchPerMonth AS trader WITH (NOLOCK) ON upload.RowNumber = trader.RowNumber
		WHERE upload.SessionId = @SessionId
	END
	ELSE -- edit
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @Trader = Trader
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Trader NVARCHAR(100)) AS data

		EXEC sp_xml_removedocument @idoc

		SELECT @owpEventDate = EventDate
		FROM dbo.OWPMatch WITH (NOLOCK)
		WHERE OWPMatchId = @OWPMatchId

		SELECT @UserId = dbo.OWP_GetUserIdByUsername(@Trader)

		INSERT INTO #tblAssignmentInfo (
			OWPMatchId
			,owpEventDate
			,UserId
			,MinorBettypeId
			,MinorMatchId
			,ParentMatchId
			)
		SELECT DISTINCT om.OWPMatchId
			,om.EventDate
			,a.UserId
			,minor.MinorBettypeId
			,minor.MinorMatchId
			,minor.ParentMatchId
		FROM dbo.OWPMatch AS om WITH (NOLOCK)
			INNER JOIN dbo.Assignment AS a WITH (NOLOCK) ON om.OWPMatchId = a.OWPMatchId
			LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON om.OWPMatchId = minor.MinorMatchId
		WHERE (
				(
					CAST(om.EventDate AS DATE) = @owpEventDate
					AND om.KickOffTime >= @Timeline
					)
				OR (
					CAST(om.EventDate AS DATE) = CAST(DATEADD(dd, 1, @owpEventDate) AS DATE)
					AND om.KickOffTime < @Timeline
					)
				)
			AND om.OWPMatchId <> @OWPMatchId
			AND a.UserId = @UserId
			AND a.AssignmentType = @Assignee

		UPDATE assignment
		SET assignment.ParentMatchId = assignment.OWPMatchId
		FROM #tblAssignmentInfo AS assignment WITH (ROWLOCK)
		WHERE assignment.MinorBettypeId IS NULL

		INSERT INTO #tblCountMatchTrading (
			UserId
			,owpEventDate
			,Total
			)
		SELECT data.UserId
			,data.owpEventDate
			,COUNT(1)
		FROM (
			SELECT ParentMatchId
				,owpEventDate
				,UserId
			FROM #tblAssignmentInfo WITH (NOLOCK)
			GROUP BY ParentMatchId
				,owpEventDate
				,UserId
			) AS data
		GROUP BY data.UserId
			,data.owpEventDate

		-- get trade 5 matches/day
		INSERT INTO #tblTrade5MatchPerDay (
			UserId
			,owpEventDate
			)
		SELECT UserId
			,owpEventDate
		FROM #tblCountMatchTrading WITH (NOLOCK)
		GROUP BY UserId
			,owpEventDate
		HAVING SUM(Total) >= @MaxMatchTradingPerDay - 1

		INSERT INTO #tblTrade5MatchPerDay (
			UserId
			,owpEventDate
			)
		SELECT t.UserId
			,[Date]
		FROM dbo.Trade5MatchPerDay AS t WITH (NOLOCK)
			INNER JOIN #tblCountMatchTrading AS t1 WITH (NOLOCK) ON t.UserId = t1.UserId
		WHERE MONTH(t.[Date]) = MONTH(t1.owpEventDate)
			AND YEAR(t.[Date]) = YEAR(t1.owpEventDate)
			AND t.[Date] NOT IN (
				SELECT DISTINCT owpEventDate
				FROM #tblCountMatchTrading WITH (NOLOCK)
				)

		IF EXISTS (
				SELECT 1
				FROM #tblTrade5MatchPerDay WITH (NOLOCK)
				GROUP BY UserId
					,MONTH(owpEventDate)
					,YEAR(owpEventDate)
				HAVING COUNT(1) >= 2
				)
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

	DROP TABLE #tblAssignmentInfo

	DROP TABLE #tblCountMatchTrading

	DROP TABLE #tblTrade5MatchPerDay

	DROP TABLE #tbl2Trade5MatchPerMonth

	DROP TABLE #tblCombine2Trade5MatchPerMonth
END