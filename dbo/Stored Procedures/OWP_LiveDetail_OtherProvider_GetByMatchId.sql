/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
create PROCEDURE [dbo].[OWP_LiveDetail_OtherProvider_GetByMatchId] @OWPMatchId INT
AS
/*  
 Created: Raymond.Le@20180813
 Task : Get other provider list by OWP match Id
 DB: bodb_OWP

Revisions:
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20190109@Raymond.Le: Rename Provider to Other Provider, Runner to Provider - [Redmine: #107257]
*/
BEGIN
	SET NOCOUNT ON

	SELECT op.OtherProviderId
		,op.OtherProviderName
	FROM dbo.MatchInfo AS mi WITH (NOLOCK)
		CROSS APPLY dbo.fnc_SplitStrings(mi.OtherProvider, ',') AS data
		INNER JOIN dbo.OtherProvider AS op WITH (NOLOCK) ON RTRIM(LTRIM(data.val)) = op.OtherProviderId
	WHERE mi.OWPMatchId = @OWPMatchId

END