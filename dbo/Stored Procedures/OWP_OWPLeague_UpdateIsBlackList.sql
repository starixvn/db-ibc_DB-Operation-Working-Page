CREATE PROCEDURE [dbo].[OWP_OWPLeague_UpdateIsBlackList] @UserId INT
	,@OWPLeagueId INT
	,@IsBlackList BIT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*  
Created: 20170302@Tim.Trinh  
Task : Update IsBlackList
DB: bodb_OWP  
  
Revisions:
Param's Explanation:
     
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@LogDataOld NVARCHAR(MAX)
		,@Xml XML

	BEGIN TRY
		-- Log  
		SET @StartRun = GETDATE()
		SET @Xml = (
				SELECT OWPLeagueId AS '@mt'
					,IsBlackList AS '@ibl'
				FROM dbo.OWPLeague WITH (NOLOCK)
				WHERE OWPLeagueId = @OWPLeagueId
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

		-- update 
		UPDATE league WITH (UPDLOCK, ROWLOCK)
		SET league.IsBlackList = @IsBlackList
		FROM dbo.OWPLeague AS league
		WHERE league.OWPLeagueId = @OWPLeagueId

		-- For write log  
		SET @Xml = (
				SELECT OWPLeagueId AS '@id'
					,IsBlackList AS '@ibl'
				FROM dbo.OWPLeague WITH (NOLOCK)
				WHERE OWPLeagueId = @OWPLeagueId
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		IF ISNULL(@LogData, '') <> ''
			OR ISNULL(@LogDataOld, '') <> ''
		BEGIN
			EXEC dbo.OWP_WriteLog @CreatorId = @UserId
				,@SPName = 'OWP_OWPLeague_UpdateIsBlackList'
				,@LoggedDate = @StartRun
				,@Duration = @Duration
				,@ObjectId = NULL
				,@Data = @LogData
				,@DataOld = @LogDataOld
		END
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Update IsBlackList failed. Please try again.'
			,@ErrCode = 6101

		RETURN
	END CATCH
END