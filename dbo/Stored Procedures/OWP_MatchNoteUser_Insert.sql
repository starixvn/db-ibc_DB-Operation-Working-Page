
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_MatchNoteUser_Insert] @MatchNoteId INT
	,@CreatorId INT
	,@UserIds TVP_INT READONLY
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20170109@Tim.Trinh
Task : Insert new MatchNoteUser
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868] 
	20181012@Leo.Vo: Notify assignee - [Redmine: #102867]
*/
BEGIN
	SET NOCOUNT ON

	-- Log
	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@Xml XML

	SET @StartRun = GETDATE()

	BEGIN TRY
		-- insert
		INSERT INTO dbo.MatchNoteUser (
			MatchNoteId
			,UserId
			,IsViewed
			)
		SELECT @MatchNoteId
			,Id
			,0
		FROM @UserIds

		-- For write log
		SET @Xml = (
				SELECT MatchNoteId AS '@mn'
					,UserId AS '@us'
					,IsViewed AS '@st'
				FROM dbo.MatchNoteUser WITH (NOLOCK)
				WHERE MatchNoteId = @MatchNoteId
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @CreatorId
			,@SPName = 'OWP_MatchNoteUser_Insert'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @MatchNoteId
			,@Data = @LogData
			,@DataOld = NULL
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Insert user note failed. Please try again.'
			,@ErrCode = 5701 -- ActionId + 01

		RETURN
	END CATCH
END