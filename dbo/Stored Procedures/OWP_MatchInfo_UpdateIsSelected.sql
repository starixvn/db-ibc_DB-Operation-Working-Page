CREATE PROCEDURE [dbo].[OWP_MatchInfo_UpdateIsSelected] @UserId INT
	,@OWPMatchIds NVARCHAR(MAX) = ''
	,@IsSelected BIT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*  
Created: 20161220@Tim.Trinh  
Task : Update IsSelected
DB: bodb_OWP  
  
Revisions:
• 20170411@Alvin.Nguyen: update all minor match to @IsSelected when update parent
Param's Explanation:
• @OWPMatchIds: '1,2' 
     
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@LogDataOld NVARCHAR(MAX)
		,@Xml XML

	IF OBJECT_ID('tempdb..#MatchId') IS NOT NULL
	BEGIN
		DROP TABLE #MatchId
	END

	IF OBJECT_ID('tempdb..#FullMatchId') IS NOT NULL
	BEGIN
		DROP TABLE #FullMatchId
	END

	CREATE TABLE #MatchId (MatchId INT)

	CREATE TABLE #FullMatchId (MatchId INT)

	IF LEN(@OWPMatchIds) > 0
	BEGIN TRY
		INSERT INTO #MatchId (MatchId)
		SELECT DISTINCT LTRIM(RTRIM(CAST(VAL AS INT)))
		FROM dbo.strSplit(@OWPMatchIds, ',')

		INSERT INTO #FullMatchId (MatchId)
		SELECT DISTINCT m.OWPMatchId
		FROM dbo.OWPMatch AS m WITH (NOLOCK)
			LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON m.OWPMatchId = minor.MinorMatchId
		WHERE m.OWPMatchId IN (
				SELECT MatchId
				FROM #MatchId
				)
			OR minor.ParentMatchId IN (
				SELECT MatchId
				FROM #MatchId
				)

		-- Log  
		SET @StartRun = GETDATE()
		SET @Xml = (
				SELECT info.OWPMatchId AS '@mt'
					,info.IsSelected AS '@is'
					,info.SelectedBy AS '@sb'
					,info.IsSelectedUpdatedDate AS '@sud'
				FROM dbo.MatchInfo AS info WITH (NOLOCK)
					INNER JOIN #FullMatchId AS mid WITH (NOLOCK) ON info.OWPMatchId = mid.MatchId
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

		-- update 
		UPDATE info WITH (UPDLOCK, ROWLOCK)
		SET info.IsSelected = @IsSelected
			,info.SelectedBy = @UserId
			,info.IsSelectedUpdatedDate = GETDATE()
		FROM dbo.MatchInfo AS info
			INNER JOIN #FullMatchId AS mid ON info.OWPMatchId = mid.MatchId

		-- For write log  
		SET @Xml = (
				SELECT info.OWPMatchId AS '@mt'
					,info.IsSelected AS '@is'
					,info.SelectedBy AS '@sb'
					,info.IsSelectedUpdatedDate AS '@sud'
				FROM dbo.MatchInfo AS info WITH (NOLOCK)
					INNER JOIN #FullMatchId AS mid WITH (NOLOCK) ON info.OWPMatchId = mid.MatchId
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_MatchInfo_UpdateIsSelected'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = NULL
			,@Data = @LogData
			,@DataOld = @LogDataOld
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Update Selected failed. Please try again.'
			,@ErrCode = 5101

		RETURN
	END CATCH

	DROP TABLE #MatchId

	DROP TABLE #FullMatchId
END