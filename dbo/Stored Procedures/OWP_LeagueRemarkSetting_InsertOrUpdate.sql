/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LeagueRemarkSetting_InsertOrUpdate] @UserId INT
	,@LeagueId INT
	,@OptionId INT
	,@Remarks NVARCHAR(500) = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20170316@Tim.Trinh
Task : sp main for insert/update/delete remarks
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: new structure 
   
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Weekday TINYINT = 2
		,@Weekend TINYINT = 4

	IF ISNULL(@Remarks, '') <> ''
	BEGIN
		IF NOT EXISTS (
				SELECT 1
				FROM dbo.LeagueRemarkSetting WITH (NOLOCK)
				WHERE LeagueId = @LeagueId
					AND OptionId = @OptionId
				)
		BEGIN
			EXEC dbo.OWP_LeagueRemarkSetting_Insert @UserId = @UserId
				,@LeagueId = @LeagueId
				,@OptionId = @OptionId
				,@Remarks = @Remarks
				,@ErrCode = @ErrCode OUTPUT
				,@ErrMsg = @ErrMsg OUTPUT

			IF @ErrCode = 0
			BEGIN
				UPDATE dbo.LeagueSetting WITH (ROWLOCK, UPDLOCK)
				SET ModifiedBy = @UserId
					,ModifiedDate = GETDATE()
				WHERE LeagueId = @LeagueId
					AND OptionsId IN (@OptionId, @OptionId + @Weekday, @OptionId + @Weekend)
			END
		END
		ELSE
		BEGIN
			EXEC dbo.OWP_LeagueRemarkSetting_Update @UserId = @UserId
				,@LeagueId = @LeagueId
				,@OptionId = @OptionId
				,@Remarks = @Remarks
				,@ErrCode = @ErrCode OUTPUT
				,@ErrMsg = @ErrMsg OUTPUT
			
			IF @ErrCode = 0
			BEGIN
				UPDATE dbo.LeagueSetting WITH (ROWLOCK, UPDLOCK)
				SET ModifiedBy = @UserId
					,ModifiedDate = GETDATE()
				WHERE LeagueId = @LeagueId
					AND OptionsId IN (@OptionId, @OptionId + @Weekday, @OptionId + @Weekend)
			END
		END
	END
	ELSE
	BEGIN
		EXEC dbo.OWP_LeagueRemarkSetting_Delete @UserId = @UserId
			,@LeagueId = @LeagueId
			,@OptionId = @OptionId
			,@ErrCode = @ErrCode OUTPUT
			,@ErrMsg = @ErrMsg OUTPUT
	END
END