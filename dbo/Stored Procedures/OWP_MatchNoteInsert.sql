/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_MatchNoteInsert] @UserId INT
	,@OWPMatchId INT
	,@Note NVARCHAR(max)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20160922@John.Ngo
Task : Insert new MatchNote
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: new structure 
*/

BEGIN
	SET NOCOUNT ON

	DECLARE @MatchNoteId INT
		,@RowCount INT

	IF @Note <> ''
	BEGIN TRY
		-- Log
		DECLARE @StartRun DATETIME
			,@EndRun DATETIME
			,@Duration INT
			,@LogMatchNoteData NVARCHAR(MAX)
			,@Xml XML

		SET @StartRun = GETDATE()

		--
		INSERT INTO dbo.MatchNote (
			OWPMatchId
			,CreatedDate
			,CreatedBy
			,Note
			)
		SELECT @OWPMatchId
			,GETDATE() AS CreatedDate
			,@UserId AS CreatedBy
			,CAST(VAL AS NVARCHAR(MAX)) AS Note
		FROM dbo.strSplit(@Note, '@#')

		SELECT @MatchNoteId = SCOPE_IDENTITY()

		-- For write log
		SET @Xml = (
				SELECT @OWPMatchId AS '@mt'
					,@Note AS '@nt'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogMatchNoteData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_MatchNoteInsert'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @OWPMatchId
			,@Data = @LogMatchNoteData
			,@DataOld = NULL
	END TRY

	BEGIN CATCH
		DELETE
		FROM dbo.MatchNote WITH (ROWLOCK)
		WHERE MatchNoteId = @MatchNoteId

		SELECT @ErrMsg = 'Insert new note failed. Please try again.'
			,@ErrCode = 1001 -- ActionId + 01

		RETURN
	END CATCH
END