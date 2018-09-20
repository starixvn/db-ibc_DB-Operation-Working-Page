CREATE PROCEDURE [dbo].[OWP_LiveDetailNoteGet] 
	@OWPMatchId INT
AS
/*
	Created: 2016-10-04@Aaron
	Task : Get new Match Detail Notes
	DB: bodb_OWP

	Revisions:   
	*/
BEGIN
	SET NOCOUNT ON

	SELECT   [MatchNoteId]
			,[CreatedDate]
			,c.Username AS [CreatedBy]
			,[Note] AS MatchNoteContent
	FROM [dbo].[MatchNote] m WITH (NOLOCK)
	LEFT JOIN bodb02.dbo.CustInfo c WITH (NOLOCK) ON m.CreatedBy = c.CustId
	WHERE m.OWPMatchId = @OWPMatchId
	ORDER BY [CreatedDate] DESC
END