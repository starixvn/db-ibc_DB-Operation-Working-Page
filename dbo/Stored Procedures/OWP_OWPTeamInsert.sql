/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OWPTeamInsert] 
	 @UserId INT
	,@OWPTeamName	NVARCHAR(50)	 
	,@TeamId	INT = 0 OUTPUT
	,@ErrCode	INT = 0 OUTPUT
	,@ErrMsg	NVARCHAR(200) = '' OUTPUT	
/*
Created: 20160922@John.Ngo
Task : Insert new team
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
*/
AS
BEGIN
	SET NOCOUNT ON
		
	SELECT TOP 1 @TeamId = OWPTeamId FROM dbo.OWPTeam WITH (NOLOCK) WHERE OWPTeamName = @OWPTeamName
	IF ISNULL(@TeamId, 0) <> 0
	BEGIN
		SELECT @ErrCode = 701 --ActionId + 01
			  ,@ErrMsg = 'The team name already exists.'

		RETURN
	END

	SELECT @TeamId = 0
	
	BEGIN TRY
		
		-- For write log
		DECLARE 
			@StartRun					DATETIME,
			@EndRun						DATETIME,
			@Duration					INT,
			@LogTeamData				NVARCHAR(MAX),	
			@Xml						XML

		SET @StartRun = GETDATE()
	
		INSERT INTO dbo.OWPTeam (
			[OWPTeamName]
			)
		VALUES (
			@OWPTeamName
			)

		SELECT @TeamId = SCOPE_IDENTITY()
		
		-- Write log 
		SET @Xml = (
						SELECT	
							@OWPTeamName	AS '@tn'		
						 FOR XML PATH('z'), ROOT('r')
					)

		SET @LogTeamData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun) 

		
		EXEC	dbo.OWP_WriteLog
				@CreatorId	= @UserId,	--@CreatorId
				@SPName		= 'OWP_OWPTeamInsert',
				@LoggedDate	= @StartRun,
				@Duration	= @Duration,
				@ObjectId	= @TeamId,
				@Data		= @LogTeamData,
				@DataOld	= NULL
	END TRY
	
	BEGIN CATCH
		SELECT @ErrMsg = 'Insert new team failed. Please try again.'
			,@ErrCode = 702 --ActionId + 01

		DELETE
		FROM dbo.OWPTeam WITH (ROWLOCK)
		WHERE OWPTeamId = @TeamId

		RETURN
	END CATCH
END