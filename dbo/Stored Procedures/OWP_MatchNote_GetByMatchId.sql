/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_MatchNote_GetByMatchId] 
	@OWPMatchId INT
AS
/*
Created: 20180810@Leo
Task : Get match note by OWPMatchId
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	SELECT   mn.MatchNoteId
			,(CASE WHEN u.Nickname IS NOT NULL THEN u.Nickname ELSE u.Username END) AS Username
			,mn.Note
	FROM dbo.MatchNote mn WITH (NOLOCK)
	INNER JOIN dbo.[User] AS u WITH (NOLOCK)
	ON mn.CreatedBy = u.UserId
	WHERE mn.OWPMatchId = @OWPMatchId
	ORDER BY [CreatedDate] DESC
END