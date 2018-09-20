CREATE PROCEDURE [dbo].[OWP_LeagueRemarkSetting_Insert] @UserId INT
	,@LeagueId INT
	,@OptionId INT
	,@Remarks NVARCHAR(500)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20170316@Tim.Trinh
Task : insert remarks
DB: bodb_OWP

Revisions:
   
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@Xml XML

	BEGIN TRY
		SET @StartRun = GETDATE()

		INSERT INTO dbo.LeagueRemarkSetting (
			LeagueId
			,OptionId
			,Remarks
			)
		VALUES (
			@LeagueId
			,@OptionId
			,@Remarks
			)

		-- write log
		SET @Xml = (
				SELECT @LeagueId AS '@lid'
					,@OptionId AS '@opt'
					,@Remarks AS '@r'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_LeagueRemarkSetting_Insert'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @LeagueId
			,@Data = @LogData
			,@DataOld = NULL
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Insert remarks failed. Please try again.'
			,@ErrCode = 6801 -- ActionId + 01

		RETURN
	END CATCH
END