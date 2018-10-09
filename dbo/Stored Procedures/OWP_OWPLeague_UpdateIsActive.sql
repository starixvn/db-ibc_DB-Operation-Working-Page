/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OWPLeague_UpdateIsActive] @UserId INT
	,@OWPLeagueId INT
	,@IsActive BIT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*  
Created: 20170302@Tim.Trinh
Task : Update IsActive
DB: bodb_OWP
  
Revisions:
	20181009@Raymond.Le: new structure 
     
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
				SELECT OWPLeagueId AS '@lid'
					,IsActive AS '@ia'
				FROM dbo.OWPLeague WITH (NOLOCK)
				WHERE OWPLeagueId = @OWPLeagueId
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

		-- update 
		UPDATE league WITH (UPDLOCK, ROWLOCK)
		SET league.IsActive = @IsActive
		FROM dbo.OWPLeague AS league
		WHERE league.OWPLeagueId = @OWPLeagueId

		-- For write log  
		SET @Xml = (
				SELECT OWPLeagueId AS '@lid'
					,IsActive AS '@ia'
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
				,@SPName = 'OWP_OWPLeague_UpdateIsActive'
				,@LoggedDate = @StartRun
				,@Duration = @Duration
				,@ObjectId = NULL
				,@Data = @LogData
				,@DataOld = @LogDataOld
		END
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Update IsActive failed. Please try again.'
			,@ErrCode = 6001

		RETURN
	END CATCH
END