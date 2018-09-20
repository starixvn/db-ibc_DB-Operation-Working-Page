CREATE PROCEDURE [dbo].[OWP_LiveDetail_GetHomeAwayToSendMessage] @OWPMatchId INT
AS
/*
Created: 20161129@Tim.Trinh
Task : get home name and away name to send message
DB: bodb_OWP

Revisions:
   20170412@Tim.Trinh: remove get data from bodb02
*/
BEGIN
	SET NOCOUNT ON

	SELECT DISTINCT home.OWPTeamName AS HomeName
		,away.OWPTeamName AS AwayName
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
		LEFT JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON home.OWPTeamId = m.OWPHomeId
		LEFT JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON away.OWPTeamId = m.OWPAwayId
	WHERE m.OWPMatchId = @OWPMatchId
END