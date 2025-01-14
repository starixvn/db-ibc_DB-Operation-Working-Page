
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_SyncMatchInfoToAdminSite_GetDefaultSecondAcceptValue]
AS
/*
Created: 20241223@Tim
Task: get default second accept value
DB: bodb_OWP

Revisions:
	20241223@Tim: initial - [Redmine: #212957]
*/
BEGIN
	SET NOCOUNT ON;

    SELECT ms.FT_HDP
        ,rrm.Value 'Main'
        ,rrc.Value 'Corner'
        ,rrt.Value 'TotalBooking'
        ,rrf.Value 'Fantasy'
    FROM dbo.MaxbetSetting AS ms WITH(NOLOCK)
        LEFT JOIN dbo.RefResource AS rrm WITH(NOLOCK) ON ms.SecondAccept_Main = rrm.ResourceId
        AND rrm.RefName = 'MatchOffer'
        LEFT JOIN dbo.RefResource AS rrc WITH(NOLOCK) ON ms.SecondAccept_Corner = rrc.ResourceId
        AND rrc.RefName = 'MatchOffer'
        LEFT JOIN dbo.RefResource AS rrt WITH(NOLOCK) ON ms.SecondAccept_TotalBooking = rrt.ResourceId
        AND rrt.RefName = 'MatchOffer'
        LEFT JOIN dbo.RefResource AS rrf WITH(NOLOCK) ON ms.SecondAccept_Fantasy = rrf.ResourceId
        AND rrf.RefName = 'MatchOffer'
END