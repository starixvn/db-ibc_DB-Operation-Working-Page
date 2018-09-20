CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber11] @SessionId NVARCHAR(100) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(MAX) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 11: Duplicate trader
 DB: bodb_OWP

 Revisions:
    20170407@Tim.Trinh: remove check data in bodb02
	20180416@leo.vo: add FM, AIO
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 11
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(MAX)
		,@MatchLengthToTrade SMALLINT
		,@MaxTradingMatchesSameTime TINYINT
		,@Trader NVARCHAR(100)
		,@Bettype INT
		,@UserId INT
		,@owpEventDate DATETIME
		,@idoc INT
	-- assignment type
	DECLARE @Assignee TINYINT = 1

	CREATE TABLE #tblBettype (Bettype INT)

	CREATE TABLE #tblCornerBettype (Bettype INT)

	CREATE TABLE #tblAssignmentInfo (
		OWPMatchId INT
		,owpEventDate DATETIME
		,Home NVARCHAR(200)
		,Away NVARCHAR(200)
		,UserId INT
		,MinorMatchId INT NULL
		,ParentMatchId INT NULL
		,MinorBettypeId INT NULL
		)

	CREATE TABLE #tblAssignmentUploading (
		RowNumber INT
		,OWPMatchId INT NULL
		,owpEventDate DATETIME NULL
		,League NVARCHAR(2000)
		,Home NVARCHAR(200)
		,Away NVARCHAR(200)
		,UserId INT
		,Trader NVARCHAR(100)
		,IsViolated BIT
		,MinorBettypeId INT NULL
		,ParentMatchId INT NULL
		,ParentRowNumber INT NULL
		)

	CREATE TABLE #tblCountMatchTrading (
		UserId INT
		,Total INT
		)

	CREATE TABLE #tblMatchDuplicateTrader (
		RowNumber INT
		,Match NVARCHAR(MAX)
		)

	CREATE TABLE #tblCombineMatchDuplicateTrader (
		RowNumber INT
		,Match NVARCHAR(MAX)
		)

	SELECT @RuleResultType = RuleResultType
		,@Message = MessageFormat
	FROM dbo.ValidationRule WITH (NOLOCK)
	WHERE RuleId = @RuleId

	SELECT @Passed = ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'RuleResultType'
		AND Value = 'Passed'

	SELECT @MatchLengthToTrade = Value
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'MatchLengthToTrade'

	SELECT @MaxTradingMatchesSameTime = Value
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'MaxTradingMatchesSameTime'

	INSERT INTO #tblBettype
	VALUES (1)
		,(3)
		,(5)
		,(7)
		,(8)
		,(15)

	INSERT INTO #tblCornerBettype (Bettype)
	SELECT MinorBettypeId
	FROM dbo.MinorBettype WITH (NOLOCK)
	WHERE MinorBettypeName LIKE '%corner%'

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
			,IsViolated
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
			,0
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
		FROM #tblAssignmentUploading AS upload
			LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON upload.Trader = u.Nickname
			OR upload.Trader = u.Username
		WHERE u.UserId IS NULL

		-- update UserId
		UPDATE upload
		SET upload.UserId = u.UserId
		FROM #tblAssignmentUploading AS upload
			INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON upload.Trader = u.Nickname
			OR upload.Trader = u.Username

		-- get assignment info		
		INSERT INTO #tblAssignmentInfo (
			OWPMatchId
			,owpEventDate
			,Home
			,Away
			,UserId
			,MinorMatchId
			,ParentMatchId
			,MinorBettypeId
			)
		SELECT DISTINCT om.OWPMatchId
			,DATEADD(dd, DATEDIFF(dd, 0, om.EventDate), CAST(om.KickOffTime AS DATETIME))
			,home.OWPTeamName
			,away.OWPTeamName
			,a.UserId
			,minor.MinorMatchId
			,minor.ParentMatchId
			,minor.MinorBettypeId
		FROM dbo.OWPMatch AS om WITH (NOLOCK)
			INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON om.OWPLeagueId = league.OWPLeagueId
			INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
			INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
			INNER JOIN dbo.Assignment AS a WITH (NOLOCK) ON om.OWPMatchId = a.OWPMatchId
			INNER JOIN #tblAssignmentUploading AS upload WITH (NOLOCK) ON a.UserId = upload.UserId
			LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON om.OWPMatchId = minor.MinorMatchId
		WHERE upload.owpEventDate IS NOT NULL
			AND (
				DATEADD(dd, DATEDIFF(dd, 0, om.EventDate), CAST(om.KickOffTime AS DATETIME)) <> upload.owpEventDate
				OR league.OWPLeagueName <> upload.League
				OR home.OWPTeamName <> upload.Home
				OR away.OWPTeamName <> upload.Away
				)
			AND a.AssignmentType = @Assignee
			AND a.Bettype IN (
				SELECT Bettype
				FROM #tblBettype WITH (NOLOCK)
				
				UNION
				SELECT Bettype
				FROM #tblCornerBettype WITH (NOLOCK)
				)
			AND DATEADD(dd, DATEDIFF(dd, 0, om.EventDate), CAST(om.KickOffTime AS DATETIME)) BETWEEN DATEADD(MINUTE, - 1 * @MatchLengthToTrade, upload.owpEventDate)
				AND DATEADD(MINUTE, @MatchLengthToTrade, upload.owpEventDate)

		-- calculate
		INSERT INTO #tblCountMatchTrading (
			UserId
			,Total
			)
		SELECT upload.UserId
			,COUNT(1)
		FROM #tblAssignmentUploading AS upload WITH (NOLOCK)
			INNER JOIN #tblAssignmentUploading AS upload1 WITH (NOLOCK) ON upload.Trader = upload1.Trader
		WHERE upload.RowNumber <> upload1.RowNumber
			AND (
				ISNULL(upload.MinorBettypeId, 0) = 0
				OR (
					ISNULL(upload.MinorBettypeId, 0) <> 0
					AND ISNULL(upload.ParentMatchId, 0) = 0
					AND ISNULL(upload.ParentRowNumber, 0) = 0
					)
				OR (
					ISNULL(upload.MinorBettypeId, 0) <> 0
					AND ISNULL(upload.ParentMatchId, 0) <> 0
					AND ISNULL(upload.ParentRowNumber, 0) = 0
					AND upload.ParentMatchId <> upload1.OWPMatchId
					)
				OR (
					ISNULL(upload.MinorBettypeId, 0) <> 0
					AND ISNULL(upload.ParentMatchId, 0) = 0
					AND ISNULL(upload.ParentRowNumber, 0) <> 0
					AND upload.ParentRowNumber <> upload1.RowNumber
					)
				OR (
					ISNULL(upload.MinorBettypeId, 0) <> 0
					AND ISNULL(upload.ParentMatchId, 0) <> 0
					AND ISNULL(upload.ParentRowNumber, 0) = 0
					AND upload.ParentMatchId = upload1.OWPMatchId
					AND upload.MinorBettypeId IN (
						SELECT Bettype
						FROM #tblCornerBettype WITH (NOLOCK)
						)
					)
				OR (
					ISNULL(upload.MinorBettypeId, 0) <> 0
					AND ISNULL(upload.ParentMatchId, 0) = 0
					AND ISNULL(upload.ParentRowNumber, 0) <> 0
					AND upload.ParentRowNumber = upload1.RowNumber
					AND upload.MinorBettypeId IN (
						SELECT Bettype
						FROM #tblCornerBettype WITH (NOLOCK)
						)
					)
				)
			AND (
				ISNULL(upload1.MinorBettypeId, 0) = 0
				OR (
					ISNULL(upload1.MinorBettypeId, 0) <> 0
					AND ISNULL(upload1.ParentMatchId, 0) = 0
					AND ISNULL(upload1.ParentRowNumber, 0) = 0
					)
				OR (
					ISNULL(upload1.MinorBettypeId, 0) <> 0
					AND ISNULL(upload1.ParentMatchId, 0) <> 0
					AND ISNULL(upload1.ParentRowNumber, 0) = 0
					AND upload1.ParentMatchId <> upload.OWPMatchId
					)
				OR (
					ISNULL(upload1.MinorBettypeId, 0) <> 0
					AND ISNULL(upload1.ParentMatchId, 0) = 0
					AND ISNULL(upload1.ParentRowNumber, 0) <> 0
					AND upload1.ParentRowNumber <> upload.RowNumber
					)
				OR (
					ISNULL(upload1.MinorBettypeId, 0) <> 0
					AND ISNULL(upload1.ParentMatchId, 0) <> 0
					AND ISNULL(upload1.ParentRowNumber, 0) = 0
					AND upload1.ParentMatchId = upload.OWPMatchId
					AND upload1.MinorBettypeId IN (
						SELECT Bettype
						FROM #tblCornerBettype WITH (NOLOCK)
						)
					)
				OR (
					ISNULL(upload1.MinorBettypeId, 0) <> 0
					AND ISNULL(upload1.ParentMatchId, 0) = 0
					AND ISNULL(upload1.ParentRowNumber, 0) <> 0
					AND upload1.ParentRowNumber = upload.RowNumber
					AND upload1.MinorBettypeId IN (
						SELECT Bettype
						FROM #tblCornerBettype WITH (NOLOCK)
						)
					)
				)
			AND upload.owpEventDate IS NOT NULL
			AND upload1.owpEventDate BETWEEN DATEADD(MINUTE, - 1 * @MatchLengthToTrade, upload.owpEventDate)
				AND DATEADD(MINUTE, @MatchLengthToTrade, upload.owpEventDate)
		GROUP BY upload.UserId

		INSERT INTO #tblCountMatchTrading (
			UserId
			,Total
			)
		SELECT assignment.UserId
			,COUNT(1)
		FROM #tblAssignmentInfo AS assignment WITH (NOLOCK)
			INNER JOIN #tblAssignmentUploading AS upload WITH (NOLOCK) ON assignment.UserId = upload.UserId
		WHERE upload.owpEventDate IS NOT NULL
			AND (
				assignment.MinorMatchId IS NULL
				OR (
					ISNULL(upload.OWPMatchId, 0) <> 0
					AND assignment.ParentMatchId <> upload.OWPMatchId
					)
				OR (
					ISNULL(upload.OWPMatchId, 0) <> 0
					AND assignment.ParentMatchId = upload.OWPMatchId
					AND assignment.MinorBettypeId IN (
						SELECT Bettype
						FROM #tblCornerBettype WITH (NOLOCK)
						)
					)
				)
			AND (
				upload.MinorBettypeId IS NULL
				OR (ISNULL(upload.ParentMatchId, 0) <> ISNULL(assignment.OWPMatchId, 0))
				OR (
					ISNULL(upload.ParentMatchId, 0) = ISNULL(assignment.OWPMatchId, 0)
					AND upload.MinorBettypeId IN (
						SELECT Bettype
						FROM #tblCornerBettype WITH (NOLOCK)
						)
					)
				)
			AND assignment.owpEventDate BETWEEN DATEADD(MINUTE, - 1 * @MatchLengthToTrade, upload.owpEventDate)
				AND DATEADD(MINUTE, @MatchLengthToTrade, upload.owpEventDate)
		GROUP BY assignment.UserId

		-- update IsViolated
		UPDATE upload
		SET upload.IsViolated = 1
		FROM #tblAssignmentUploading AS upload
		WHERE upload.UserId IN (
				SELECT UserId
				FROM #tblCountMatchTrading WITH (NOLOCK)
				GROUP BY UserId
				HAVING SUM(Total) > @MaxTradingMatchesSameTime
				)

		-- duplicate trader
		INSERT INTO #tblMatchDuplicateTrader (
			RowNumber
			,Match
			)
		SELECT DISTINCT upload.RowNumber
			,upload1.Home + ' vs ' + upload1.Away
		FROM #tblAssignmentUploading AS upload WITH (NOLOCK)
			INNER JOIN #tblAssignmentUploading AS upload1 WITH (NOLOCK) ON upload.UserId = upload1.UserId
		WHERE upload.RowNumber <> upload1.RowNumber
			AND (
				ISNULL(upload.MinorBettypeId, 0) = 0
				OR (
					ISNULL(upload.MinorBettypeId, 0) <> 0
					AND ISNULL(upload.ParentMatchId, 0) = 0
					AND ISNULL(upload.ParentRowNumber, 0) = 0
					)
				OR (
					ISNULL(upload.MinorBettypeId, 0) <> 0
					AND ISNULL(upload.ParentMatchId, 0) <> 0
					AND ISNULL(upload.ParentRowNumber, 0) = 0
					AND upload.ParentMatchId <> upload1.OWPMatchId
					)
				OR (
					ISNULL(upload.MinorBettypeId, 0) <> 0
					AND ISNULL(upload.ParentMatchId, 0) = 0
					AND ISNULL(upload.ParentRowNumber, 0) <> 0
					AND upload.ParentRowNumber <> upload1.RowNumber
					)
				OR (
					ISNULL(upload.MinorBettypeId, 0) <> 0
					AND ISNULL(upload.ParentMatchId, 0) <> 0
					AND ISNULL(upload.ParentRowNumber, 0) = 0
					AND upload.ParentMatchId = upload1.OWPMatchId
					AND upload.MinorBettypeId IN (
						SELECT Bettype
						FROM #tblCornerBettype WITH (NOLOCK)
						)
					)
				OR (
					ISNULL(upload.MinorBettypeId, 0) <> 0
					AND ISNULL(upload.ParentMatchId, 0) = 0
					AND ISNULL(upload.ParentRowNumber, 0) <> 0
					AND upload.ParentRowNumber = upload1.RowNumber
					AND upload.MinorBettypeId IN (
						SELECT Bettype
						FROM #tblCornerBettype WITH (NOLOCK)
						)
					)
				)
			AND (
				ISNULL(upload1.MinorBettypeId, 0) = 0
				OR (
					ISNULL(upload1.MinorBettypeId, 0) <> 0
					AND ISNULL(upload1.ParentMatchId, 0) = 0
					AND ISNULL(upload1.ParentRowNumber, 0) = 0
					)
				OR (
					ISNULL(upload1.MinorBettypeId, 0) <> 0
					AND ISNULL(upload1.ParentMatchId, 0) <> 0
					AND ISNULL(upload1.ParentRowNumber, 0) = 0
					AND upload1.ParentMatchId <> upload.OWPMatchId
					)
				OR (
					ISNULL(upload1.MinorBettypeId, 0) <> 0
					AND ISNULL(upload1.ParentMatchId, 0) = 0
					AND ISNULL(upload1.ParentRowNumber, 0) <> 0
					AND upload1.ParentRowNumber <> upload.RowNumber
					)
				OR (
					ISNULL(upload1.MinorBettypeId, 0) <> 0
					AND ISNULL(upload1.ParentMatchId, 0) <> 0
					AND ISNULL(upload1.ParentRowNumber, 0) = 0
					AND upload1.ParentMatchId = upload.OWPMatchId
					AND upload1.MinorBettypeId IN (
						SELECT Bettype
						FROM #tblCornerBettype WITH (NOLOCK)
						)
					)
				OR (
					ISNULL(upload1.MinorBettypeId, 0) <> 0
					AND ISNULL(upload1.ParentMatchId, 0) = 0
					AND ISNULL(upload1.ParentRowNumber, 0) <> 0
					AND upload1.ParentRowNumber = upload.RowNumber
					AND upload1.MinorBettypeId IN (
						SELECT Bettype
						FROM #tblCornerBettype WITH (NOLOCK)
						)
					)
				)
			AND upload.owpEventDate IS NOT NULL
			AND upload1.owpEventDate BETWEEN DATEADD(MINUTE, - 1 * @MatchLengthToTrade, upload.owpEventDate)
				AND DATEADD(MINUTE, @MatchLengthToTrade, upload.owpEventDate)
			AND upload.IsViolated = 1
			AND upload1.IsViolated = 1

		INSERT INTO #tblMatchDuplicateTrader (
			RowNumber
			,Match
			)
		SELECT DISTINCT upload.RowNumber
			,assignment.Home + ' vs ' + assignment.Away
		FROM #tblAssignmentInfo AS assignment WITH (NOLOCK)
			INNER JOIN #tblAssignmentUploading AS upload WITH (NOLOCK) ON assignment.UserId = upload.UserId
		WHERE upload.IsViolated = 1
			AND upload.owpEventDate IS NOT NULL
			AND (
				assignment.MinorMatchId IS NULL
				OR (
					ISNULL(upload.OWPMatchId, 0) <> 0
					AND assignment.ParentMatchId <> upload.OWPMatchId
					)
				OR (
					ISNULL(upload.OWPMatchId, 0) <> 0
					AND assignment.ParentMatchId = upload.OWPMatchId
					AND assignment.MinorBettypeId IN (
						SELECT Bettype
						FROM #tblCornerBettype WITH (NOLOCK)
						)
					)
				)
			AND (
				upload.MinorBettypeId IS NULL
				OR (ISNULL(upload.ParentMatchId, 0) <> ISNULL(assignment.OWPMatchId, 0))
				OR (
					ISNULL(upload.ParentMatchId, 0) = ISNULL(assignment.OWPMatchId, 0)
					AND upload.MinorBettypeId IN (
						SELECT Bettype
						FROM #tblCornerBettype WITH (NOLOCK)
						)
					)
				)
			AND assignment.owpEventDate BETWEEN DATEADD(MINUTE, - 1 * @MatchLengthToTrade, upload.owpEventDate)
				AND DATEADD(MINUTE, @MatchLengthToTrade, upload.owpEventDate)

		-- combine
		INSERT INTO #tblCombineMatchDuplicateTrader (
			RowNumber
			,Match
			)
		SELECT data.RowNumber
			,STUFF((
					SELECT DISTINCT '; ' + Match
					FROM #tblMatchDuplicateTrader WITH (NOLOCK)
					WHERE RowNumber = data.RowNumber
					FOR XML PATH('')
					), 1, 2, '')
		FROM (
			SELECT DISTINCT RowNumber
			FROM #tblMatchDuplicateTrader WITH (NOLOCK)
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
				WHEN m.RowNumber IS NOT NULL THEN REPLACE(@Message, '<content>', m.Match)
				ELSE '' END
				) AS [Message]
		FROM dbo.AssignmentUploading AS upload WITH (NOLOCK)
			LEFT JOIN #tblCombineMatchDuplicateTrader AS m WITH (NOLOCK) ON upload.RowNumber = m.RowNumber
		WHERE upload.SessionId = @SessionId
	END
	ELSE -- edit
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @Trader = Trader
			,@Bettype = Bettype
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Trader NVARCHAR(100), Bettype INT) AS data

		EXEC sp_xml_removedocument @idoc

		SELECT @owpEventDate = DATEADD(dd, DATEDIFF(dd, 0, EventDate), CAST(KickOffTime AS DATETIME))
		FROM dbo.OWPMatch WITH (NOLOCK)
		WHERE OWPMatchId = @OWPMatchId

		SELECT @UserId = dbo.OWP_GetUserIdByUsername(@Trader)

		INSERT INTO #tblAssignmentInfo (
			OWPMatchId
			,owpEventDate
			,Home
			,Away
			,UserId
			,MinorMatchId
			,ParentMatchId
			,MinorBettypeId
			)
		SELECT om.OWPMatchId
			,DATEADD(dd, DATEDIFF(dd, 0, om.EventDate), CAST(om.KickOffTime AS DATETIME))
			,home.OWPTeamName
			,away.OWPTeamName
			,a.UserId
			,minor.MinorMatchId
			,minor.ParentMatchId
			,minor.MinorBettypeId
		FROM dbo.OWPMatch AS om WITH (NOLOCK)
			INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
			INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
			INNER JOIN dbo.Assignment AS a WITH (NOLOCK) ON om.OWPMatchId = a.OWPMatchId
			LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON om.OWPMatchId = minor.MinorMatchId
		WHERE om.OWPMatchId <> @OWPMatchId
			AND a.UserId = @UserId
			AND a.AssignmentType = @Assignee
			AND a.Bettype IN (
				SELECT Bettype
				FROM #tblBettype WITH (NOLOCK)
				
				UNION ALL
				SELECT Bettype
				FROM #tblCornerBettype WITH (NOLOCK)
				)
			AND DATEADD(dd, DATEDIFF(dd, 0, om.EventDate), CAST(om.KickOffTime AS DATETIME)) BETWEEN DATEADD(MINUTE, - 1 * @MatchLengthToTrade, @owpEventDate)
				AND DATEADD(MINUTE, @MatchLengthToTrade, @owpEventDate)

		INSERT INTO #tblCountMatchTrading (
			UserId
			,Total
			)
		SELECT UserId
			,COUNT(1)
		FROM #tblAssignmentInfo WITH (NOLOCK)
		WHERE MinorMatchId IS NULL
			OR ParentMatchId <> @OWPMatchId
			OR (
				ParentMatchId = @OWPMatchId
				AND MinorBettypeId IN (
					SELECT Bettype
					FROM #tblCornerBettype WITH (NOLOCK)
					)
				)
		GROUP BY UserId

		IF (
				SELECT SUM(Total)
				FROM #tblCountMatchTrading WITH (NOLOCK)
				GROUP BY UserId
				) > @MaxTradingMatchesSameTime - 1
		BEGIN
			INSERT INTO #tblMatchDuplicateTrader (
				RowNumber
				,Match
				)
			SELECT 1
				,Home + ' vs ' + Away
			FROM #tblAssignmentInfo WITH (NOLOCK)
			WHERE MinorMatchId IS NULL
				OR ParentMatchId <> @OWPMatchId
				OR (
					ParentMatchId = @OWPMatchId
					AND MinorBettypeId IN (
						SELECT Bettype
						FROM #tblCornerBettype WITH (NOLOCK)
						)
					)

			SELECT @RuleResultType AS ResultType
				,REPLACE(@Message, '<content>', STUFF((
							SELECT DISTINCT '; ' + Match
							FROM #tblMatchDuplicateTrader WITH (NOLOCK)
							WHERE RowNumber = 1
							FOR XML PATH('')
							), 1, 2, '')) AS [Message]
		END
		ELSE
		BEGIN
			SELECT @Passed AS ResultType
				,'' AS [Message]
		END
	END

	DROP TABLE #tblBettype

	DROP TABLE #tblCornerBettype

	DROP TABLE #tblAssignmentInfo

	DROP TABLE #tblAssignmentUploading

	DROP TABLE #tblCountMatchTrading

	DROP TABLE #tblMatchDuplicateTrader

	DROP TABLE #tblCombineMatchDuplicateTrader
END