CREATE PROCEDURE [dbo].[OWP_LeagueRemarkSetting_Delete] @UserId INT
	,@LeagueId INT
	,@OptionId INT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20170316@Tim.Trinh
Task : delete remarks
DB: bodb_OWP

Revisions:
   
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@OldData NVARCHAR(MAX)
		,@Xml XML

	BEGIN TRY
		-- Log
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
		SET @OldData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

		-- delete
		DELETE
		FROM dbo.LeagueRemarkSetting WITH (ROWLOCK, UPDLOCK)
		WHERE LeagueId = @LeagueId
			AND OptionId = @OptionId

		-- Write log		
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_LeagueRemarkSetting_Delete'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @LeagueId
			,@Data = NULL
			,@DataOld = @OldData
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Delete remark failed. Please try again.'
			,@ErrCode = 7001

		RETURN
	END CATCH
END