/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OWPLeague_UpdateIsBlackList] @ActorId INT
	,@OWPLeagueId INT
	,@IsBlackList BIT
AS
/*  
Created: 20170302@Tim.Trinh  
Task : Update IsBlackList
DB: bodb_OWP  
  
Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]   
	20200407@Tyler.Dang: New structure of Maxbet Management - [Redmine: #131923]   
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@LogDataOld NVARCHAR(MAX)
		,@Xml XML

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
			EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
				,@SPName = 'OWP_OWPLeague_UpdateIsBlackList'
				,@LoggedDate = @StartRun
				,@Duration = @Duration
				,@ObjectId = @OWPLeagueId
				,@Data = @LogData
				,@DataOld = @LogDataOld
		END
END