/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_Agent_GetByMatchId] @OWPMatchId INT
AS
/*  
 Created: Raymond.Le@20180813
 Task : Get Agent list by OWP match Id
 DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: new structure
*/
BEGIN
	SET NOCOUNT ON

	SELECT a.AgentId
		,a.AgentName
	FROM dbo.MatchInfo AS mi WITH (NOLOCK)
		CROSS APPLY dbo.fnc_SplitStrings(mi.Agent, ',') AS data
		INNER JOIN dbo.Agent AS a WITH (NOLOCK) ON RTRIM(LTRIM(data.val)) = a.AgentId
	WHERE mi.OWPMatchId = @OWPMatchId

END