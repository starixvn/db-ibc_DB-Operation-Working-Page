/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_API_GetExistingInfoSiteMatches] @Ids NVARCHAR(MAX)
AS
/*    
Created: 20240708@Johnny
Task : Get InfoSiteMatch
DB: bodb_OWP
    
Revisions:     
    20240708@Johnny: initial SP - [Redmine: #201604]
    20241106@Frankie: change update type - [Redmine: #212795]
    20241127@Tim: get Remark2, MatchStatus [Redmine: #214095]
*/
BEGIN
    SET NOCOUNT ON;
    DECLARE @tempMatch TABLE(InfoSiteMatchId INT);

	INSERT INTO @tempMatch
    SELECT DISTINCT value
    FROM STRING_SPLIT(@Ids, ',');

    -- select from infosite match
    SELECT DISTINCT 
        m.InfoSiteMatchId,
        m.LeagueName,
        m.HomeName,
        m.AwayName,
        m.EventDateTime,
        m.TV,
        m.IPTV,
        m.[OtherProvider],
        m.[Round],
        m.[Remark],
        m.Remark2,
        m.HomeRemark,
        m.AwayRemark,
        m.Division,
        m.MatchStatus,
        CASE
			WHEN ec.InfositeId IS NULL
			THEN 0
			ELSE 1
        END AS IsCheck
    FROM dbo.[InfoSiteMatch] AS m WITH(NOLOCK)
		INNER JOIN @tempMatch AS t ON m.InfoSiteMatchId = t.InfoSiteMatchId
		LEFT JOIN dbo.EventPickingConfirmed AS ec WITH(NOLOCK) ON m.InfoSiteMatchId = ec.InfositeId
END;