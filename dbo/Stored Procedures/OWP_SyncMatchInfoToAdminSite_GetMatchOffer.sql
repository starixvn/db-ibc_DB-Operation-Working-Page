
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_SyncMatchInfoToAdminSite_GetMatchOffer] @MatchIds VARCHAR(MAX)
AS
/*
Created: 20241223@Tim
Task: sync match offer to AdminSite
DB: bodb_OWP

Revisions:
	20241223@Tim: initial - [Redmine: #212957]
*/
BEGIN
	SET NOCOUNT ON;

    CREATE TABLE #tblMatch (OWPMatchId INT)

    INSERT INTO #tblMatch (OWPMatchId)
    SELECT value
    FROM STRING_SPLIT(@MatchIds, ',') AS m

    SELECT m.OWPMatchId
        ,mo.MatchOfferId AS 'ResourceId'
        ,rr.[Value]
    FROM dbo.MatchOfferDetail AS mo WITH (NOLOCK)
        INNER JOIN dbo.RefResource AS rr WITH (NOLOCK) ON mo.MatchOfferId = rr.ResourceId
        AND rr.RefName = 'MatchOffer'
        INNER JOIN #tblMatch AS m ON mo.OWPMatchId = m.OWPMatchId

    DROP TABLE #tblMatch
END