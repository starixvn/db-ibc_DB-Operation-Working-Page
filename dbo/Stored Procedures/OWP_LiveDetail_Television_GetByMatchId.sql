/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_Television_GetByMatchId] @OWPMatchId INT
AS
/*  
 Created: Raymond.Le@20180813
 Task : Get television list by OWP match Id
 DB: bodb_OWP

 Revisions:
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	SELECT tv.TVId
		,tv.TVCode
		,tv.Color
	FROM dbo.MatchInfo AS mi WITH (NOLOCK)
		CROSS APPLY dbo.fnc_SplitStrings(mi.TVCode, ',') AS data
		INNER JOIN dbo.Television AS tv WITH (NOLOCK) ON RTRIM(LTRIM(data.val)) = tv.TVId
	WHERE mi.OWPMatchId = @OWPMatchId

END