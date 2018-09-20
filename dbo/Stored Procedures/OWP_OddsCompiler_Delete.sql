CREATE PROCEDURE [dbo].[OWP_OddsCompiler_Delete] @UserId INT
	,@OWPMatchId INT
	,@RecommendOdds NVARCHAR(MAX)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*          
 Created: 20170317@Alvin.Nguyen
 Task : delete odds compiler
 DB: bodb_OWP          
          
 Revisions:      
 Param's Explanation:
	• @RecommendOdds:  <Root><Row Bettype="1" Handicap="0.5" /></Root>      
*/
BEGIN
	SET NOCOUNT ON

	-- Log
	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@idoc INT
		,@1X2 INT = 5

	SET @StartRun = GETDATE()
	SET @Duration = 0

	IF OBJECT_ID('tempdb..#RecommendOdds') IS NOT NULL
	BEGIN
		DROP TABLE #RecommendOdds
	END

	CREATE TABLE #RecommendOdds (
		OWPMatchId INT
		,Bettype INT
		,HDP SMALLMONEY
		)

	CREATE TABLE #tblLogs (
		CreatorId INT
		,LoggedDate DATETIME
		,Duration INT
		,ObjectId INT
		,ActionId INT
		,Data NVARCHAR(MAX)
		,DataOld NVARCHAR(MAX)
		)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@RecommendOdds

	INSERT INTO #RecommendOdds (
		OWPMatchId
		,Bettype
		,HDP
		)
	SELECT DISTINCT @OWPMatchId
		,data.Bettype
		,CASE 
			WHEN data.Handicap = '' THEN NULL
			ELSE CAST(data.Handicap AS SMALLMONEY)
			END AS Handicap
	FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Bettype INT, Handicap VARCHAR(5)) AS data

	EXEC sp_xml_removedocument @idoc

	UPDATE #RecommendOdds
	SET HDP = 0
	WHERE Bettype = @1X2

	BEGIN TRY
		INSERT INTO #tblLogs (
			CreatorId
			,LoggedDate
			,ObjectId
			,ActionId
			,Duration
			,Data
			,DataOld
			)
		SELECT @UserId
			,@StartRun
			,odd.OWPMatchId
			,71
			,@Duration
			,NULL
			,REPLACE(CONVERT(NVARCHAR(MAX), (
						SELECT odd.Id AS '@id'
							,odd.OWPMatchId AS '@mt'
							,odd.Bettype AS '@bt'
							,odd.HDP AS '@hdp'
							,odd.Choice AS '@c'
							,odd.Odds AS '@o'
						FOR XML PATH('z')
							,ROOT('r')
						)), '" />', '"/"')
		FROM #RecommendOdds AS tmp
			LEFT JOIN dbo.MatchRecommendOdds AS odd WITH (NOLOCK) ON tmp.OWPMatchId = odd.OWPMatchId
			AND tmp.HDP = odd.HDP
			AND tmp.Bettype = odd.Bettype

		DELETE odd
		FROM dbo.MatchRecommendOdds AS odd
		WHERE EXISTS (
				SELECT 1
				FROM #RecommendOdds
				WHERE OWPMatchId = odd.OWPMatchId
					AND Bettype = odd.Bettype
					AND (
						(
							HDP IS NULL
							AND odd.HDP IS NULL
							)
						OR (
							HDP IS NOT NULL
							AND HDP = odd.HDP
							)
						)
				)

		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		--write log
		INSERT INTO UserLog (
			CreatorId
			,LoggedDate
			,ActionId
			,ObjectId
			,Duration
			,Data
			,DataOld
			)
		SELECT CreatorId
			,LoggedDate
			,ActionId
			,ObjectId
			,@Duration
			,Data
			,DataOld
		FROM #tblLogs
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Delete odds compiler failed. Please try again.'
			,@ErrCode = 7101 -- ActionId + 01

		RETURN
	END CATCH

	DROP TABLE #tblLogs

	DROP TABLE #RecommendOdds
END