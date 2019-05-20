/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_OtherProvider_GetByMatchId] @OWPMatchId INT
AS
/*  
 Created: Raymond.Le@20180813
 Task : Get other provider list by OWP match Id
 DB: bodb_OWP

Revisions:
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20190109@Raymond.Le: Rename Provider to Other Provider, Runner to Provider - [Redmine: #107257]
	20190509@Kane.Le: Change schema of Provider, OtherProvider, Agent, Television - [Redmine: #112918]
*/
BEGIN
	SET NOCOUNT ON

	SELECT op.OtherProviderId
		,op.OtherProviderName
	FROM dbo.MatchOtherProvider AS mi WITH (NOLOCK)		 
		INNER JOIN dbo.OtherProvider AS op WITH (NOLOCK) ON mi.OtherProviderId = op.OtherProviderId
	WHERE mi.OWPMatchId = @OWPMatchId

END