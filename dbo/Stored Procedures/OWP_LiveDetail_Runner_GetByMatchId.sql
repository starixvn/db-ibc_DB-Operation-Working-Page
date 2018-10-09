/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_Runner_GetByMatchId] @OWPMatchId INT
AS
/*  
 Created: Raymond.Le@20180813
 Task : Get provider list by OWP match Id
 DB: bodb_OWP

 Revisions:
	20181009@Raymond.Le: new structure
*/
BEGIN
	SET NOCOUNT ON

	SELECT r.RunnerId
		,r.RunnerName
	FROM dbo.MatchInfo AS mi WITH (NOLOCK)
		CROSS APPLY dbo.fnc_SplitStrings(mi.Runner, ',') AS data
		INNER JOIN dbo.Runner AS r WITH (NOLOCK) ON RTRIM(LTRIM(data.val)) = r.RunnerId
	WHERE mi.OWPMatchId = @OWPMatchId

END