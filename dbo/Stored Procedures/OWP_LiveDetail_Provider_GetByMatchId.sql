/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_Provider_GetByMatchId] @OWPMatchId INT
AS
/*  
 Created: Raymond.Le@20180813
 Task : Get provider list by OWP match Id
 DB: bodb_OWP

 Revisions:
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20190109@Raymond.Le: Rename Provider to Other Provider, Runner to Provider - [Redmine: #107257]
	20190509@Kane.Le: Change schema of Provider, OtherProvider, Agent, Television - [Redmine: #112918]
*/
BEGIN
	SET NOCOUNT ON

	SELECT r.ProviderId
		,r.ProviderName
	FROM dbo.MatchProvider AS mi WITH (NOLOCK) 
		INNER JOIN dbo.[Provider] AS r WITH (NOLOCK) ON mi.ProviderId = r.ProviderId
	WHERE mi.OWPMatchId = @OWPMatchId

END