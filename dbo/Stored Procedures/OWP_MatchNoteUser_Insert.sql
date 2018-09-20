

/****** Object:  Stored Procedure dbo.OWP_MatchNoteUser_Insert    Script Date: 1/16/2017 3:13:31 PM ******/
CREATE PROCEDURE [dbo].[OWP_MatchNoteUser_Insert] @MatchNoteId INT
	,@CreatorId INT
	,@UserIds NVARCHAR(MAX) = ''
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20170109@Tim.Trinh
Task : Insert new MatchNoteUser
DB: bodb_OWP

Revisions:
   
*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #tmpUser (UserId INT)

	INSERT INTO #tmpUser (UserId)
	SELECT CAST(RTRIM(LTRIM(val)) AS INT)
	FROM dbo.strSplit(@UserIds, ',')

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
			,UserId
			,0
		FROM #tmpUser WITH (NOLOCK)

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