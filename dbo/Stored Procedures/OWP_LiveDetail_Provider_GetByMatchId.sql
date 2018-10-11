/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_Provider_GetByMatchId] @OWPMatchId INT
AS
/*  
 Created: Raymond.Le@20180813
 Task : Get provider list by OWP match Id
 DB: bodb_OWP

Revisions:
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	SELECT p.ProviderId
		,p.ProviderName
	FROM dbo.MatchInfo AS mi WITH (NOLOCK)
		CROSS APPLY dbo.fnc_SplitStrings(mi.Provider, ',') AS data
		INNER JOIN dbo.Provider AS p WITH (NOLOCK) ON RTRIM(LTRIM(data.val)) = p.ProviderId
	WHERE mi.OWPMatchId = @OWPMatchId

END