CREATE PROCEDURE [dbo].[OWP_MatchNoteViewUpdate] @UserId INT
	,@MatchId INT
AS
/*
Created: 20161102@Simon.Huynh
Task : update IsViewed
DB: bodb_OWP

Revisions:
   
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Start DATETIME = GETDATE()
		,@Old XML
		,@New XML
		,@OldData NVARCHAR(MAX)
		,@NewData NVARCHAR(MAX)

	SET @Old = (
			SELECT @MatchId '@mt'
				,@UserId '@us'
				,mn.MatchNoteId '@nid'
				,mnu.IsViewed 'st'
			FROM dbo.MatchNoteUser AS mnu WITH (NOLOCK)
				INNER JOIN dbo.MatchNote AS mn WITH (NOLOCK) ON mn.MatchNoteId = mnu.MatchNoteId
			WHERE mn.OWPMatchId = @MatchId
				AND mnu.UserId = @UserId
			FOR XML PATH('z')
				,ROOT('r')
			)

	UPDATE mnu WITH (ROWLOCK, UPDLOCK)
	SET mnu.IsViewed = 1
	FROM dbo.MatchNoteUser AS mnu
		INNER JOIN dbo.MatchNote AS mn WITH (NOLOCK) ON mn.MatchNoteId = mnu.MatchNoteId
	WHERE mn.OWPMatchId = @MatchId
		AND mnu.UserId = @UserId

	INSERT INTO dbo.MatchNoteUser (
		MatchNoteId
		,UserId
		,IsViewed
		)
	SELECT MatchNoteId
		,@UserId
		,1
	FROM dbo.MatchNote WITH (NOLOCK)
	WHERE OWPMatchId = @MatchId
		AND NOT EXISTS (
			SELECT 1
			FROM dbo.MatchNoteUser AS mnu WITH (NOLOCK)
				INNER JOIN dbo.MatchNote AS mn WITH (NOLOCK) ON mnu.MatchNoteId = mn.MatchNoteId
			WHERE mn.OWPMatchId = @MatchId
				AND mnu.UserId = @UserId
			)

	DECLARE @Duration INT = DATEDIFF(MILLISECOND, @start, GETDATE())

	SET @New = (
			SELECT @MatchId '@mt'
				,@UserId '@us'
				,mn.MatchNoteId '@nid'
				,mnu.IsViewed 'st'
			FROM dbo.MatchNoteUser AS mnu WITH (NOLOCK)
				INNER JOIN dbo.MatchNote AS mn WITH (NOLOCK) ON mn.MatchNoteId = mnu.MatchNoteId
			WHERE mn.OWPMatchId = @MatchId
				AND mnu.UserId = @UserId
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @OldData = REPLACE(CONVERT(NVARCHAR(MAX), @Old), '" />', '"/"')
	SET @NewData = REPLACE(CONVERT(NVARCHAR(MAX), @New), '" />', '"/"')

	EXEC dbo.OWP_WriteLog @CreatorId = @UserId
		,@SPName = 'OWP_MatchNoteViewUpdate'
		,@LoggedDate = @Start
		,@Duration = @Duration
		,@ObjectId = @MatchId
		,@Data = @NewData
		,@DataOld = @OldData
END