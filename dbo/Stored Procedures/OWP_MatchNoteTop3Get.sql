CREATE PROCEDURE [dbo].[OWP_MatchNoteTop3Get] @UserId INT
	,@MatchId INT
AS
/*
Created: 20161101@Simon.Huynh
Task : get top 3 match note
DB: bodb_OWP

Revisions:
   
*/
BEGIN
	SET NOCOUNT ON

	SELECT TOP 3 mn.Note
	FROM dbo.MatchNote AS mn WITH (NOLOCK)
		LEFT JOIN dbo.MatchNoteUser AS mnu WITH (NOLOCK) ON mn.MatchNoteId = mnu.MatchNoteId
		AND mnu.UserId = @UserId
	WHERE mn.OWPMatchId = @MatchId
	ORDER BY mn.CreatedDate DESC
END