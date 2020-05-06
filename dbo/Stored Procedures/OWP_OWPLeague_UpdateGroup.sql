/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OWPLeague_UpdateGroup]  @ActorId INT
	,@OWPLeagueId INT
	,@LeagueGroupId INT
AS
/*  
Created: 20200407@Tyler.Dang  
Task : Update league group
DB: bodb_OWP  
  
Revisions:
	20200407@Tyler.Dang: Init - [Redmine: #131923]   
*/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@LogDataOld NVARCHAR(MAX)
		,@Xml XML

		-- Log  
		SET @StartRun = GETDATE()
		SET @Xml = (
				SELECT OWPLeagueId AS '@lid'
					,CategoryId AS '@ci'
				FROM dbo.OWPLeague WITH (NOLOCK)
				WHERE OWPLeagueId = @OWPLeagueId
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

		-- update 
		UPDATE league WITH (UPDLOCK, ROWLOCK)
		SET league.CategoryId = @LeagueGroupId
		FROM dbo.OWPLeague AS league
		WHERE league.OWPLeagueId = @OWPLeagueId

		-- For write log  
		SET @Xml = (
				SELECT OWPLeagueId AS '@lid'
					,CategoryId AS '@ci'
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
			EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
				,@SPName = 'OWP_OWPLeague_UpdateGroup'
				,@LoggedDate = @StartRun
				,@Duration = @Duration
				,@ObjectId = @OWPLeagueId
				,@Data = @LogData
				,@DataOld = @LogDataOld
		END
END