
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[Task_OWP_LSTReport_CaculateByDate]
AS
/*    
 Created: 20191211@Kane.Le
 Task : Caculate report by date of LST Report
 DB: bodb_OWP    
    
 Revisions:
	20191211@Kane.Le: Initial SP - [Redmine: #124448]	
	20190107@Kane.Le: Delete report when unassign - [Redmine: #124448]	
*/
BEGIN
	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF;

	DECLARE @EventDate DATE = GETDATE();
	DECLARE @FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 3, @EventDate), '12:00:00')
		,@ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '11:59:59')
	-- Insert statements for procedure here
	-- DECLARE CONSTANTS
	DECLARE @HandicapHDP INT = 1
		,@OverUnderOU INT = 3
		,@1H_HandicapHDP INT = 7
		,@1H_OverUnder INT = 8
		,@1X2 INT = 5
		,@1H_1X2 INT = 15
		,@LA_Bettype INT = - 1002
		,@MinorBettype_NextCorner INT = - 4
		,@MinorBettype_NextBooking INT = - 7
		,@MinorBettype_15Mins INT = - 1
		,@MinorBettype_10Mins INT = - 2
		,@LeagueCategoryId_MJ INT = 1
		,@LeagueCategoryId_MIN_1 INT = 2
		,@LeagueCategoryId_MIN_2 INT = 3
		,@LeagueCategoryId_MIN_3 INT = 4

	CREATE TABLE #tblTempAssignmentReportMainMatch (
		Id INT IDENTITY
		,UserId INT
		,Username NVARCHAR(50)
		,OWPMatchId INT
		,Bettype INT
		,EventDate DATE
		,IsSoloMatch BIT
		,LeagueId INT
		,LeagueName NVARCHAR(500)
		,LeagueCategoryId INT
		,MinorBettypeId INT
		)

	CREATE TABLE #tblTempAssignmentReportMinorMatch (
		Id INT IDENTITY
		,UserId INT
		,Username NVARCHAR(50)
		,OWPMatchId INT
		,Bettype INT
		,EventDate DATE
		,IsSoloMatch BIT
		,LeagueId INT
		,LeagueName NVARCHAR(500)
		,LeagueCategoryId INT
		,MinorBettypeId INT
		,OWPMatchParentId INT
		)

	INSERT INTO #tblTempAssignmentReportMainMatch (
		UserId
		,Username
		,OWPMatchId
		,Bettype
		,EventDate
		,IsSoloMatch
		,LeagueId
		,LeagueName
		,LeagueCategoryId
		,MinorBettypeId
		)
	SELECT u.UserId
		,u.Username
		,ma.OWPMatchId
		,ass.Bettype
		,ma.EventDateTime
		,mi.IsSoloMatch
		,ma.OWPLeagueId
		,la.OWPLeagueName
		,la.CategoryId
		,mn.MinorBettypeId
	FROM dbo.[User] u WITH (NOLOCK)
	LEFT JOIN dbo.Assignment ass WITH (NOLOCK) ON u.UserId = ass.UserId
	LEFT JOIN dbo.OWPMatch ma WITH (NOLOCK) ON ma.OWPMatchId = ass.OWPMatchId
	LEFT JOIN dbo.OWPLeague la WITH (NOLOCK) ON la.OWPLeagueId = ma.OWPLeagueId
	LEFT JOIN dbo.MatchInfo mi WITH (NOLOCK) ON mi.OWPMatchId = ma.OWPMatchId
	LEFT OUTER JOIN dbo.MinorMatch mn WITH (NOLOCK) ON ma.OWPMatchId = mn.MinorMatchId
	WHERE mn.MinorMatchId IS NULL
		AND ass.AssignmentType = 1
		AND ma.EventDateTime >= @FromDate
		AND ma.EventDateTime <= @ToDate
		AND ass.Bettype <> @LA_Bettype

	INSERT INTO #tblTempAssignmentReportMinorMatch (
		UserId
		,Username
		,OWPMatchId
		,Bettype
		,EventDate
		,IsSoloMatch
		,LeagueId
		,LeagueName
		,LeagueCategoryId
		,MinorBettypeId
		,OWPMatchParentId
		)
	SELECT u.UserId
		,u.Username
		,ma.OWPMatchId
		,ass.Bettype
		,ma.EventDateTime
		,mi.IsSoloMatch
		,ma.OWPLeagueId
		,la.OWPLeagueName
		,la.CategoryId
		,mn.MinorBettypeId
		,mn.ParentMatchId
	FROM dbo.[User] u WITH (NOLOCK)
	LEFT JOIN dbo.Assignment ass WITH (NOLOCK) ON u.UserId = ass.UserId
	LEFT JOIN dbo.OWPMatch ma WITH (NOLOCK) ON ma.OWPMatchId = ass.OWPMatchId
	LEFT JOIN dbo.OWPLeague la WITH (NOLOCK) ON la.OWPLeagueId = ma.OWPLeagueId
	LEFT JOIN dbo.MatchInfo mi WITH (NOLOCK) ON mi.OWPMatchId = ma.OWPMatchId
	LEFT OUTER JOIN dbo.MinorMatch mn WITH (NOLOCK) ON ma.OWPMatchId = mn.MinorMatchId
	WHERE mn.MinorMatchId IS NOT NULL
		AND ass.AssignmentType = 1
		AND ma.EventDateTime >= @FromDate
		AND ma.EventDateTime <= @ToDate
		AND ass.Bettype <> @LA_Bettype

	-- DELETE IF NOT EXISTS
	DELETE LSTReport
	WHERE ReportDate >= CAST(@FromDate AS DATE)
		AND ReportDate <= CAST(@ToDate AS DATE)

	CREATE TABLE #tblReportTypeGeneral (
		Id INT IDENTITY
		,UserId INT
		,Username NVARCHAR(50)
		,FT_HDP INT
		,FT_OU INT
		,FT_HDP_OU INT
		,EventDate DATE
		)

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,SUM(a.FT_HDP) AS 'FT_HDP'
		,SUM(a.FT_OU) AS 'FT_OU'
		,SUM(a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) < 1
					THEN 1
				ELSE 0
				END AS 'FT_HDP'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) < 1
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMainMatch
			WHERE Bettype IN (
					@HandicapHDP
					,@OverUnderOU
					)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	-- Type 1
	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND CAST(TARGET.ReportDate AS DATE) = CAST(SOURCE.EventDate AS DATE)
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND CAST(TARGET.ReportDate AS DATE) = CAST(SOURCE.EventDate AS DATE)
		THEN
			UPDATE
			SET TARGET.Type1_FT_HDP = SOURCE.FT_HDP
				,TARGET.Type1_FT_OU = SOURCE.FT_OU
				,TARGET.Type1_FT_HDPOU = SOURCE.FT_HDP_OU
				,TotalMatch = SOURCE.FT_HDP + SOURCE.FT_OU + SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,Type1_FT_HDP
				,Type1_FT_OU
				,Type1_FT_HDPOU
				,TotalMatch
				,CreatedDate
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP
				,SOURCE.FT_OU
				,SOURCE.FT_HDP_OU
				,SOURCE.FT_HDP + SOURCE.FT_OU + SOURCE.FT_HDP_OU
				,GETDATE()
				);

	-- Type 2 AUS
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) < 1
					THEN 1
				ELSE 0
				END AS 'FT_HDP'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) < 1
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMainMatch
			WHERE LeagueName LIKE '%AUSTRALIA A-LEAGUE%'
				AND Bettype IN (
					@HandicapHDP
					,@OverUnderOU
					)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.Type2_AUS_League = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,Type2_AUS_League
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- Type 2 AUS Conner
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) < 1
					THEN 1
				ELSE 0
				END AS 'FT_HDP'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) < 1
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMinorMatch
			WHERE LeagueName LIKE '%AUSTRALIA A-LEAGUE%'
				AND MinorBettypeId = @MinorBettype_NextCorner
				AND Bettype IN (
					@HandicapHDP
					,@OverUnderOU
					)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.Type2_AUS_League_Corner = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,Type2_AUS_League_Corner
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- Type 2 JAP Division1
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) < 1
					THEN 1
				ELSE 0
				END AS 'FT_HDP'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) < 1
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMainMatch
			WHERE LeagueName LIKE '%JAPAN J-LEAGUE DIVISION 1%'
				AND Bettype IN (
					@HandicapHDP
					,@OverUnderOU
					)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.Type2_JAP_Divison1 = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,Type2_JAP_Divison1
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- Type 2 JAP Division2
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) < 1
					THEN 1
				ELSE 0
				END AS 'FT_HDP'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) < 1
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMainMatch
			WHERE LeagueName LIKE '%JAPAN J-LEAGUE DIVISION 2%'
				AND Bettype IN (
					@HandicapHDP
					,@OverUnderOU
					)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.Type2_JAP_Divison2 = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,Type2_JAP_Divison2
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- Type 3 Solo MJ
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) < 1
					THEN 1
				ELSE 0
				END AS 'FT_HDP'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) < 1
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMainMatch
			WHERE IsSoloMatch = 1
				AND Bettype IN (
					@HandicapHDP
					,@OverUnderOU
					)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.Type3_Solo_Major = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,Type3_Solo_Major
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- Type 4 Major League
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) < 1
					THEN 1
				ELSE 0
				END AS 'FT_HDP'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) < 1
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMainMatch
			WHERE LeagueCategoryId = @LeagueCategoryId_MJ
				AND Bettype IN (
					@HandicapHDP
					,@OverUnderOU
					)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.Type4_Major = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,Type4_Major
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- Type 4 MIN-1 League
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) < 1
					THEN 1
				ELSE 0
				END AS 'FT_HDP'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) < 1
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMainMatch
			WHERE LeagueCategoryId = @LeagueCategoryId_MIN_1
				AND Bettype IN (
					@HandicapHDP
					,@OverUnderOU
					)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.Type4_Minor1 = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,Type4_Minor1
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- Type 4 MIN-2 League
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) < 1
					THEN 1
				ELSE 0
				END AS 'FT_HDP'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) < 1
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMainMatch
			WHERE LeagueCategoryId = @LeagueCategoryId_MIN_2
				AND Bettype IN (
					@HandicapHDP
					,@OverUnderOU
					)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.Type4_Minor2 = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,Type4_Minor2
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- Type 4 MIN-3 League
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) < 1
					THEN 1
				ELSE 0
				END AS 'FT_HDP'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) < 1
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMainMatch
			WHERE LeagueCategoryId = @LeagueCategoryId_MIN_3
				AND Bettype IN (
					@HandicapHDP
					,@OverUnderOU
					)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.Type4_Minor3 = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,Type4_Minor3
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- Type 4 1ST MJ League
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) < 1
					THEN 1
				ELSE 0
				END AS 'FT_HDP'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) < 1
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMainMatch
			WHERE LeagueCategoryId = 1
				AND Bettype IN (
					@HandicapHDP
					,@OverUnderOU
					)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.Type4_1ST_Major = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,Type4_1ST_Major
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- Type 4 1ST(Other) MJ League
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @1H_HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @1H_OverUnder
								THEN 1
							ELSE NULL
							END) < 1
					THEN 1
				ELSE 0
				END AS 'FT_HDP'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @1H_HandicapHDP
								THEN 1
							ELSE NULL
							END) < 1
					AND COUNT(CASE 
							WHEN tmp.Bettype = @1H_OverUnder
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @1H_HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @1H_OverUnder
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMainMatch
			WHERE LeagueCategoryId <> 1
				AND Bettype IN (
					@1H_HandicapHDP
					,@1H_OverUnder
					)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.Type4_1ST_Other = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,Type4_1ST_Other
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- Type 4 FANTASY
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) < 1
					THEN 1
				ELSE 0
				END AS 'FT_HDP'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) < 1
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMainMatch
			WHERE LeagueName LIKE '%FANTASY MATCH%'
				AND Bettype IN (
					@HandicapHDP
					,@OverUnderOU
					)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.Type4_Fantasy = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,Type4_Fantasy
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- Type 4 Conner/NextConner Conner
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) < 1
					THEN 1
				ELSE 0
				END AS 'FT_HDP'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) < 1
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMinorMatch
			WHERE MinorBettypeId = @MinorBettype_NextCorner
				AND Bettype IN (
					@HandicapHDP
					,@OverUnderOU
					)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.Type4_Corner_NextCorner = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,Type4_Corner_NextCorner
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- Type4_15M
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) < 1
					THEN 1
				ELSE 0
				END AS 'FT_HDP'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) < 1
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMinorMatch
			WHERE MinorBettypeId = @MinorBettype_15Mins
				AND Bettype IN (
					@HandicapHDP
					,@OverUnderOU
					)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.Type4_15M = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,Type4_15M
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- Type4_10M
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) < 1
					THEN 1
				ELSE 0
				END AS 'FT_HDP'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) < 1
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMinorMatch
			WHERE MinorBettypeId = @MinorBettype_10Mins
				AND Bettype IN (
					@HandicapHDP
					,@OverUnderOU
					)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.Type4_10M = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,Type4_10M
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- Type4_TB (TotalBooking, count as NextBooking)
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) < 1
					THEN 1
				ELSE 0
				END AS 'FT_HDP'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) < 1
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMinorMatch
			WHERE MinorBettypeId = @MinorBettype_NextBooking
				AND Bettype IN (
					@HandicapHDP
					,@OverUnderOU
					)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.Type4_TotalBooking = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,Type4_TotalBooking
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- Type 4 PK SO
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) < 1
					THEN 1
				ELSE 0
				END AS 'FT_HDP'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) < 1
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMinorMatch
			WHERE LeagueName LIKE '%- PENALTY SHOOT-OUT'
				AND Bettype IN (
					@HandicapHDP
					,@OverUnderOU
					)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.Type4_PKSO = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,Type4_PKSO
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- Type 4 WIN
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) < 1
					THEN 1
				ELSE 0
				END AS 'FT_HDP'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) < 1
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @HandicapHDP
								THEN 1
							ELSE NULL
							END) > 0
					AND COUNT(CASE 
							WHEN tmp.Bettype = @OverUnderOU
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMinorMatch
			WHERE LeagueName LIKE '%- WINNER'
				AND Bettype IN (
					@HandicapHDP
					,@OverUnderOU
					)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.Type4_Winner = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,Type4_Winner
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- PH-1x2 Major
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,0 AS 'FT_HDP'
			,0 AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @1X2
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMainMatch AS tmp
			WHERE LeagueCategoryId = @LeagueCategoryId_MJ
				AND Bettype IN (@1X2)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.PH_1X2_Major = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,PH_1X2_Major
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- PH-1x2 Minor1 MIN-1
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,0 AS 'FT_HDP'
			,0 AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @1X2
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMainMatch AS tmp
			WHERE LeagueCategoryId = @LeagueCategoryId_MIN_1
				AND Bettype IN (@1X2)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.PH_1X2_Minor1 = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,PH_1X2_Minor1
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- PH-1x2 Minor2 MIN-1
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,0 AS 'FT_HDP'
			,0 AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @1X2
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMainMatch AS tmp
			WHERE LeagueCategoryId = @LeagueCategoryId_MIN_2
				AND Bettype IN (@1X2)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.PH_1X2_Minor2 = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,PH_1X2_Minor2
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- PH-1x2 Minor3 MIN-1
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,0 AS 'FT_HDP'
			,0 AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @1X2
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMainMatch AS tmp
			WHERE LeagueCategoryId = @LeagueCategoryId_MIN_3
				AND Bettype IN (@1X2)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.PH_1X2_Minor3 = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,PH_1X2_Minor3
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	-- PH_1X2_Others
	TRUNCATE TABLE #tblReportTypeGeneral

	INSERT INTO #tblReportTypeGeneral (
		UserId
		,UserName
		,FT_HDP
		,FT_OU
		,FT_HDP_OU
		,EventDate
		)
	SELECT a.UserId
		,a.Username
		,0 AS 'FT_HDP'
		,0 AS 'FT_OU'
		,SUM(a.FT_HDP + a.FT_OU + a.FT_HDP_OU) AS 'FT_HDP_OU'
		,a.EventDate
	FROM (
		SELECT tmp.UserId
			,tmp.UserName
			,tmp.OWPMatchId
			,0 AS 'FT_HDP'
			,0 AS 'FT_OU'
			,CASE 
				WHEN COUNT(CASE 
							WHEN tmp.Bettype = @1X2
								THEN 1
							ELSE NULL
							END) > 0
					THEN 1
				ELSE 0
				END AS 'FT_HDP_OU'
			,tmp.EventDate
		FROM (
			SELECT DISTINCT UserId
				,Username
				,OWPMatchId
				,EventDate
				,Bettype
			FROM #tblTempAssignmentReportMainMatch AS tmp
			WHERE LeagueCategoryId NOT IN (
					@LeagueCategoryId_MJ
					,@LeagueCategoryId_MIN_1
					,@LeagueCategoryId_MIN_2
					,@LeagueCategoryId_MIN_3
					)
				AND Bettype IN (@1X2)
			) AS tmp
		GROUP BY tmp.UserId
			,tmp.UserName
			,tmp.EventDate
			,tmp.OWPMatchId
		) AS a
	GROUP BY a.UserId
		,a.UserName
		,a.EventDate

	MERGE dbo.LSTReport AS TARGET
	USING #tblReportTypeGeneral AS SOURCE
		ON (
				TARGET.UserId = SOURCE.UserId
				AND TARGET.ReportDate = SOURCE.EventDate
				)
	WHEN MATCHED
		AND TARGET.UserId = SOURCE.UserId
		AND TARGET.ReportDate = SOURCE.EventDate
		THEN
			UPDATE
			SET TARGET.PH_1X2_Others = SOURCE.FT_HDP_OU
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				ReportDate
				,UserId
				,Username
				,PH_1X2_Others
				)
			VALUES (
				SOURCE.EventDate
				,SOURCE.UserId
				,SOURCE.UserName
				,SOURCE.FT_HDP_OU
				);

	DROP TABLE #tblReportTypeGeneral

	DROP TABLE #tblTempAssignmentReportMainMatch

	DROP TABLE #tblTempAssignmentReportMinorMatch
END