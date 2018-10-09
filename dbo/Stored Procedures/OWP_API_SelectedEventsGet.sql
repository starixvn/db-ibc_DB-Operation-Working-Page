/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_API_SelectedEventsGet]
AS
/*    
 Created: 20161104@Long.Luu
 Task : Get all selected matches for Web API
 DB: bodb_OWP    
    
 Revisions:
 20180423@Jacob.Phan: Feature #93888 - Apply new API from InfoSite  
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @LastAPICall DATETIME;
	DECLARE @CurrentDate DATETIME = GETDATE();

	SELECT @LastAPICall = CAST(rr.VALUE AS DATETIME)
	FROM dbo.RefResource rr WITH (NOLOCK)
	WHERE rr.RefName = 'IsSelectedUpdate'

	-- GET SELECTED EVENTS
	SELECT m.InfoSiteMatchKey AS match_key, mi.IsSelected AS is_live
	FROM dbo.OWPMatch m WITH (NOLOCK)
		INNER JOIN dbo.MatchInfo mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
	WHERE mi.IsSelectedUpdatedDate BETWEEN @LastAPICall
			AND @CurrentDate
		AND LEN(ISNULL(m.InfoSiteMatchKey, '')) > 0 
	ORDER BY m.EventDate DESC
END