/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LeagueManagement_Insert] @ActorId INT
	,@OWPLeagueId INT
AS
/*
Created: 20200414@Tyler.Dang
Task : Add league setting
DB: bodb_OWP

Revisions:
   20200414@Tyler.Dang: Init Redmine: #132506
*/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@Xml XML

	SET @StartRun = GETDATE()

	INSERT INTO [dbo].[NewLeagueSetting]
           ([OWPLeagueId]
           ,[Category]
		   ,[IsApplied]
		   ,[LastModifiedBy])
    VALUES
           (@OWPLeagueId
           ,N'Live'
		   ,0
		   ,@ActorId)

	SET @Xml = (
				SELECT @OWPLeagueId AS '@lid'
					,SCOPE_IDENTITY() AS '@lsid'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	IF ISNULL(@LogData, '') <> ''
		BEGIN
			EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
				,@SPName = 'OWP_LeagueManagement_Insert'
				,@LoggedDate = @StartRun
				,@Duration = @Duration
				,@ObjectId = @OWPLeagueId
				,@Data = @LogData
		END
END