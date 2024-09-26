
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_API_SyncMaxbet_GetMatchOffer] @OWPMatchId INT
AS

/*
Created: 20201203@Tyler.Dang
Task: sync maxbet
DB: bodb_OWP

Revisions:
	20201203@Tyler.Dang: Get MatchOffer - [Redmine: #145096]
	20222005@carlos.nguyen: Exclude 'KO+15', 'Fast Market' - [Redmine: #173041]
	20220809@Liam.Pham: get offer line default - [Redmine: #176781]
*/

    BEGIN
        SELECT [OWPMatchId], 
               [MatchOfferId] AS 'ResourceId', 
               rr.[Value]
        FROM [bodb_OWP].[dbo].[MatchOfferDetail] AS mo
             INNER JOIN dbo.RefResource AS rr ON mo.MatchOfferId = rr.ResourceId
                                                 AND rr.RefName = 'MatchOffer'
        WHERE OWPMatchId = @OWPMatchId 
    END;