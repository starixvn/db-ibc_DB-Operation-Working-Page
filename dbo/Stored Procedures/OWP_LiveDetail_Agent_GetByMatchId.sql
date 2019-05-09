/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_Agent_GetByMatchId] @OWPMatchId INT
AS
/*  
 Created: Raymond.Le@20180813
 Task : Get Agent list by OWP match Id
 DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20190509@Kane.Le: Change schema of Provider, OtherProvider, Agent, Television - [Redmine: #112918]
*/
BEGIN
	SET NOCOUNT ON

	SELECT a.AgentId
		,a.AgentName
	FROM dbo.MatchAgent AS mi WITH (NOLOCK)
		 
		INNER JOIN dbo.Agent AS a WITH (NOLOCK) ON mi.AgentId = a.AgentId
	WHERE mi.OWPMatchId = @OWPMatchId

END