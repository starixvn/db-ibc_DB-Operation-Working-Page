/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LeagueSetting_DeleteByOptionId] @UserId INT
	,@OWPLeagueId INT
	,@OptionId INT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20170302@Tim.Trinh
Task : delete league setting
DB: bodb_OWP

Revisions:
   20170419@Tim.Trinh: delete remark
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@OldData NVARCHAR(MAX)
		,@weekday TINYINT = 2
		,@weekend TINYINT = 4
		,@Xml XML

	BEGIN TRY
		-- Log
		SET @StartRun = GETDATE()
		SET @Xml = (
				SELECT LeagueId AS '@lid'
					,Bettype AS '@bt'
					,OptionsId AS '@opt'
					,MaxBet AS '@m'
					,Spread AS '@s'
					,ModifiedBy AS '@mb'
					,ModifiedDate AS '@md'
				FROM dbo.LeagueSetting WITH (NOLOCK)
				WHERE LeagueId = @OWPLeagueId
					AND OptionsId IN (@OptionId, @OptionId + @weekday, @OptionId + @weekend)
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @OldData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

		-- delete
		DELETE ls
		FROM dbo.LeagueSetting AS ls WITH (ROWLOCK, UPDLOCK)
		WHERE ls.LeagueId = @OWPLeagueId
			AND ls.OptionsId IN (@OptionId, @OptionId + @weekday, @OptionId + @weekend)

		EXEC dbo.OWP_LeagueRemarkSetting_Delete @UserId = @UserId
			,@LeagueId = @OWPLeagueId
			,@OptionId = @OptionId
			,@ErrCode = @ErrCode OUTPUT
			,@ErrMsg = @ErrMsg OUTPUT

		-- Write log		
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		IF ISNULL(@OldData, '') <> ''
		BEGIN
			EXEC dbo.OWP_WriteLog @CreatorId = @UserId
				,@SPName = 'OWP_LeagueSetting_DeleteByOptionId'
				,@LoggedDate = @StartRun
				,@Duration = @Duration
				,@ObjectId = @OWPLeagueId
				,@Data = NULL
				,@DataOld = @OldData
		END
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Delete league setting failed. Please try again.'
			,@ErrCode = 6401

		RETURN
	END CATCH
END