/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_Market_GetByMatchId] @OWPMatchId INT
AS
/*  
 Created: Raymond.Le@20180813
 Task : Get Market list by OWP match Id
 DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: new structure
*/
BEGIN
	SET NOCOUNT ON

	SELECT mm.MarketId
		,ref.Value AS MarketName
	FROM dbo.MatchMarket AS mm WITH (NOLOCK)
	LEFT JOIN dbo.RefResource AS ref WITH (NOLOCK) ON mm.MarketId = ref.ResourceId
	WHERE ref.RefName = 'Market'
	AND mm.OWPMatchId = @OWPMatchId

END