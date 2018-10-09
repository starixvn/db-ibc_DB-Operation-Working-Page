/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber13] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(4000) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 13: 2nd trading 5 matches/day in month
 DB: bodb_OWP

 Revisions:
    20170407@Tim.Trinh: remove check data in bodb02
	20180417@leo.vo: add FM, AIO
    20180621@Leo.Vo: new structure of Upload Assignment
	20180724@Raymond.Le: Modify rule follow new uploading structure 
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 13
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(MAX)
		,@MaxMatchTradingPerDay TINYINT
		------
		,@FromTimePM TIME = '12:00:00'
		,@ToTimePM TIME = '23:59:59'
		,@UserId INT
		,@Username NVARCHAR(30)
		,@EventDate DATE
		,@idoc INT
		,@BettypeLA INT = - 1002

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
		,ParentRowNumber INT NULL
		)

	CREATE TABLE #tblAssignmentInfo (
		OWPMatchId INT
		,EventDate DATE
		,UserId INT
		,MinorBettypeId INT NULL
		,MinorMatchId INT
		,ParentMatchId INT NULL
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
			,UserId
			,Trader
			,MinorBettypeId
			,ParentRowNumber
			)
		SELECT DISTINCT RowNumber
			,OWPMatchId
			,owpEventDate
			,League
			,Home
			,Away
			,u.UserId
			,unpvt.Trader
			,MinorBettypeId
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
				,ParentRowNumber
				,TraderHDP
				,Trader1HHDP
				,TraderOU
				,Trader1HOU
				,Trader1X2
				,Trader1H1X2
			FROM dbo.AssignmentUploading WITH (NOLOCK)
			WHERE SessionId = @SessionId
			) AS upload
		UNPIVOT(Trader FOR ColumnName IN (TraderHDP, Trader1HHDP, TraderOU, Trader1HOU, Trader1X2, Trader1H1X2)) unpvt
			LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON unpvt.Trader = u.Nickname
			OR unpvt.Trader = u.Username
		WHERE ISNULL(unpvt.Trader, '') <> ''
			AND u.UserId IS NOT NULL

		-- Update parentRowNumber for main match
		UPDATE assignment
		SET assignment.ParentRowNumber = assignment.RowNumber
		FROM #tblAssignmentUploading AS assignment WITH (ROWLOCK)
		WHERE assignment.ParentRowNumber IS NULL
			AND assignment.MinorBettypeId IS NULL

		-- get trade 5 matches/day from upload file
		INSERT INTO #tblTrade5MatchPerDay (
			UserId
			,owpEventDate
			)
		SELECT data.UserId
			,data.owpEventDate
		FROM (
			SELECT ParentRowNumber
				,owpEventDate
				,UserId
			FROM #tblAssignmentUploading WITH (NOLOCK)
			GROUP BY ParentRowNumber
				,owpEventDate
				,UserId
			) AS data
		GROUP BY data.owpEventDate
			,data.UserId
		HAVING COUNT(1) >= @MaxMatchTradingPerDay

		-- get trade 5 matches/day from table dbo.Trade5MatchPerDay
		INSERT INTO #tblTrade5MatchPerDay (
			UserId
			,owpEventDate
			)
		SELECT t.UserId
			,[Date]
		FROM dbo.Trade5MatchPerDay AS t WITH (NOLOCK)
			INNER JOIN #tblTrade5MatchPerDay AS t1 WITH (NOLOCK) ON t.UserId = t1.UserId
		WHERE MONTH(t.[Date]) = MONTH(t1.owpEventDate)
			AND YEAR(t.[Date]) = YEAR(t1.owpEventDate)
			AND t.[Date] NOT IN (
				SELECT DISTINCT owpEventDate
				FROM #tblAssignmentUploading WITH (NOLOCK)
				)

		-- get 2nd trading 5 matches/day
		INSERT INTO #tbl2Trade5MatchPerMonth (
			RowNumber
			,Trader
			)
		SELECT DISTINCT (RowNumber / 10) * 10
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

		SELECT TOP 1 @UserId = data.UserId
			,@Username = data.Username
		--,@Bettype = data.Bettype
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Username NVARCHAR(30), Bettype INT, UserId INT) AS data

		EXEC sp_xml_removedocument @idoc

		SELECT @EventDate = (CASE 
				WHEN CAST(om.KickOffTime AS TIME) BETWEEN @FromTimePM
						AND @ToTimePM THEN om.EventDate
				ELSE DATEADD(DAY, - 1, om.EventDate) END
				)
		FROM dbo.OWPMatch AS om WITH (NOLOCK)
		WHERE OWPMatchId = @OWPMatchId

		INSERT INTO #tblAssignmentInfo (
			OWPMatchId
			,EventDate
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
				DATEADD(dd, DATEDIFF(dd, 0, @EventDate), '12:00:00') <= om.EventDateTime
				AND DATEADD(dd, DATEDIFF(dd, 0, @EventDate) + 1, '11:59:59') >= om.EventDateTime
				)
			AND om.OWPMatchId <> @OWPMatchId
			AND minor.ParentMatchId <> @OWPMatchId
			AND a.UserId = @UserId
			AND a.Bettype <> @BettypeLA

		UPDATE assignment
		SET assignment.ParentMatchId = assignment.OWPMatchId
		FROM #tblAssignmentInfo AS assignment WITH (ROWLOCK)
		WHERE assignment.MinorBettypeId IS NULL

		-- Get user trade 5 Match In current Event Date
		INSERT INTO #tblTrade5MatchPerDay (
			UserId
			,owpEventDate
			)
		SELECT data.UserId
			,data.EventDate
		FROM (
			SELECT ParentMatchId
				,EventDate
				,UserId
			FROM #tblAssignmentInfo WITH (NOLOCK)
			GROUP BY ParentMatchId
				,EventDate
				,UserId
			) AS data
		GROUP BY data.EventDate
			,data.UserId
		HAVING COUNT(1) >= @MaxMatchTradingPerDay - 1

		-- Get user trade5match in table Trade5MatchPerDay
		INSERT INTO #tblTrade5MatchPerDay (
			UserId
			,owpEventDate
			)
		SELECT t.UserId
			,[Date]
		FROM dbo.Trade5MatchPerDay AS t WITH (NOLOCK)
			INNER JOIN #tblTrade5MatchPerDay AS t1 WITH (NOLOCK) ON t.UserId = t1.UserId
		WHERE MONTH(t.[Date]) = MONTH(t1.owpEventDate)
			AND YEAR(t.[Date]) = YEAR(t1.owpEventDate)
			AND t.[Date] NOT IN (
				SELECT DISTINCT owpEventDate
				FROM #tblAssignmentUploading WITH (NOLOCK)
				)

		IF EXISTS (
				SELECT 1
				FROM #tblTrade5MatchPerDay WITH (NOLOCK)
				GROUP BY UserId
					,MONTH(owpEventDate)
					,YEAR(owpEventDate)
				HAVING COUNT(1) >= 1
				)
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

	DROP TABLE #tblAssignmentInfo

	DROP TABLE #tblTrade5MatchPerDay

	DROP TABLE #tbl2Trade5MatchPerMonth

	DROP TABLE #tblCombine2Trade5MatchPerMonth
END