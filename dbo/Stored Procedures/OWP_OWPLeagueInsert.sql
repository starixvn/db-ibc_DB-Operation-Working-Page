/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OWPLeagueInsert] 
	 @UserId INT
	,@OWPLeagueName NVARCHAR(2000)
	
	,@LeagueId	INT = 0 OUTPUT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
	
/*
Created: 20160922@John.Ngo
Task : Insert new OWPLeague
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
*/
AS
BEGIN
	SET NOCOUNT ON
	SELECT TOP 1 @LeagueId = OWPLeagueId FROM dbo.OWPLeague WITH (NOLOCK) WHERE OWPLeagueName = @OWPLeagueName
	IF ISNULL(@LeagueId, 0) <> 0
	BEGIN
		SELECT @ErrCode = 401 -- ActionId + 01
			  ,@ErrMsg = 'The league name already exists.'

		RETURN
	END
	
	BEGIN TRY
	
	-- Log
	DECLARE 
		@StartRun					DATETIME,
		@EndRun						DATETIME,
		@Duration					INT,
		@LogLeagueData				NVARCHAR(MAX),	
		@Xml						XML
	SET @StartRun = GETDATE()
	--
	
	INSERT INTO dbo.OWPLeague (
		OWPLeagueName
		)
	VALUES (
		@OWPLeagueName
		)
	SELECT @LeagueId = SCOPE_IDENTITY()
	
	-- For write log
	
	SET @Xml = (
					SELECT							
						@OWPLeagueName		AS '@ln'
						FOR XML PATH('z'), ROOT('r')
				)

	SET @LogLeagueData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun) 

	EXEC	dbo.OWP_WriteLog
			@CreatorId	= @UserId,
			@SPName		= 'OWP_OWPLeagueInsert',
			@LoggedDate	= @StartRun,
			@Duration	= @Duration,
			@ObjectId	= @LeagueId,
			@Data		= @LogLeagueData,
			@DataOld	= NULL
	
	END TRY
	
	BEGIN CATCH
		SELECT @ErrMsg = 'Insert new league failed. Please try again.'
			  ,@ErrCode = 402 -- ActionId + 01

		DELETE
		FROM dbo.OWPLeague WITH (ROWLOCK)
		WHERE OWPLeagueId = @LeagueId

		RETURN
	END CATCH

END