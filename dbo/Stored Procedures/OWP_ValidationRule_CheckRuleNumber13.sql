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
    20180621@Leo.Vo: new structure of Upload Assignment - [Redmine: #92868]
	20180724@Raymond.Le: Modify rule follow new uploading structure - [Redmine: #92868]
	20181031@Raymond.Le: Replace column MatchId by InfoSiteMatchId - [Redmine: #104052]
	20190405@Lita.Tang: Apply for the second account only (row 141) - [Redmine: #111068]
	20190521@Leo.Vo: Add Username value - [Feature: #113765]
	20200830@Jacob: Delete unused code - [Redmine: #137757]
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

	-- edit
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