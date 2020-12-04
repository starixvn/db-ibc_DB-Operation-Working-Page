
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_API_SyncMaxbet_GetMatchOffer] @OWPMatchId INT
AS

/*
Created: 20201203@Tyler.Dang
Task: sync maxbet
DB: bodb_OWP

Revisions:
	20201203@Tyler.Dang: Get MatchOffer - [Redmine: #145096]
*/

    BEGIN
        SELECT [OWPMatchId], 
               [MatchOfferId], 
               rr.[Value]
        FROM [bodb_OWP].[dbo].[MatchOfferDetail] AS mo
             INNER JOIN dbo.RefResource AS rr ON mo.MatchOfferId = rr.ResourceId
                                                 AND rr.RefName = 'MatchOffer'
        WHERE OWPMatchId = @OWPMatchId;
    END;