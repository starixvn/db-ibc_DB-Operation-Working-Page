
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_MatchOffer_GetByMatchId] @OWPMatchId INT
AS
/*  
 Created: Leo.Vo@20190111
 Task : Get match offer list by OWP match Id
 DB: bodb_OWP

Revisions:
	20190111@Leo.Vo: New structure of match offer - [Redmine: #107257]
*/
BEGIN
	SET NOCOUNT ON

	SELECT r.ResourceId AS Id
		,r.Value
	FROM dbo.MatchOfferDetail AS mo WITH (NOLOCK)
		INNER JOIN (
		SELECT ResourceId
			,Value
		FROM dbo.RefResource WITH (NOLOCK)
		WHERE RefName = 'MatchOffer'
		) AS r ON mo.MatchOfferId = r.ResourceId
	WHERE mo.OWPMatchId = @OWPMatchId
END