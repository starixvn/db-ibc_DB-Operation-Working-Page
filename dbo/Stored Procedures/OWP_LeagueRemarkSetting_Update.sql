/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LeagueRemarkSetting_Update] @UserId INT
	,@LeagueId INT
	,@OptionId INT
	,@Remarks NVARCHAR(500) = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20170316@Tim.Trinh
Task : update remarks
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: new structure 
   
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@RemarksOld NVARCHAR(500)
		,@LogData NVARCHAR(MAX)
		,@LogDataOld NVARCHAR(MAX)
		,@Xml XML

	SELECT @RemarksOld = Remarks
	FROM dbo.LeagueRemarkSetting WITH (NOLOCK)
	WHERE LeagueId = @LeagueId
		AND OptionId = @OptionId

	BEGIN TRY
		SET @StartRun = GETDATE()
		SET @Xml = (
				SELECT LeagueId AS '@lid'
					,OptionId AS '@opt'
					,Remarks AS '@r'
				FROM dbo.LeagueRemarkSetting WITH (NOLOCK)
				WHERE LeagueId = @LeagueId
					AND OptionId = @OptionId
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

		UPDATE dbo.LeagueRemarkSetting WITH (ROWLOCK, UPDLOCK)
		SET Remarks = @Remarks
		WHERE LeagueId = @LeagueId
			AND OptionId = @OptionId

		-- write log
		SET @Xml = (
				SELECT LeagueId AS '@lid'
					,OptionId AS '@opt'
					,Remarks AS '@r'
				FROM dbo.LeagueRemarkSetting WITH (NOLOCK)
				WHERE LeagueId = @LeagueId
					AND OptionId = @OptionId
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_LeagueRemarkSetting_Update'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @LeagueId
			,@Data = @LogData
			,@DataOld = @LogDataOld
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Update remarks failed. Please try again.'
			,@ErrCode = 6901 -- ActionId + 01

		RETURN
	END CATCH
END