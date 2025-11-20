
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventPicking_GetInfoSiteChildMatch] @Date DATE
AS

/*      
 Created: 20221102@Mira
 Task : Get child match
 DB: bodb_OWP      
 
 Revisions:
    20221102@Mira: Event picking new - [Redmine: #179302]
	20240328@Johnny: reduce select match - [Redmine: #202638]
	20250911@los: Event picking auto mark no offer  [Redmine: #236469]
    20251120@Hank: get IsNoOffer from EventPickingNoOfferMatch - [Redmine: #239738]

*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @Date), '12:00:00');
        DECLARE @ToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @Date), '11:59:59');

        -- Select InfoSiteMatch
        SELECT DISTINCT 
               m.ParentInfoSiteMatchId 'InfoSiteMatchId', 
               m.AdminSiteMatchId, 
               l.OWPLeagueName 'LeagueName', 
               h.OWPTeamName 'HomeName', 
               a.OWPTeamName 'AwayName', 
               m.SubType, 
               m.MinorBettypeId, 
               EventDateTime,
               us.[IsNoOffer] AS 'IsNoOffer',
               m.ChildMatchId
        FROM InfoSiteChildMatch m WITH(NOLOCK)
             INNER JOIN dbo.OWPTeam h WITH(NOLOCK) ON m.OWPHomeId = h.OWPTeamId
             INNER JOIN dbo.OWPTeam a WITH(NOLOCK) ON m.OWPAwayId = a.OWPTeamId
             INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
             LEFT JOIN dbo.EventPickingNoOfferMatch AS us WITH(NOLOCK) ON us.InfoSiteMatchId = m.ParentInfoSiteMatchId
                                                                          AND us.ChildMatchId = m.ChildMatchId
        WHERE 
		(
			m.EventDateTime BETWEEN @FromDateTime AND @ToDateTime
		)
		AND m.MinorBettypeId not in(
			-100, -101, -102, -109, -1189, -1190, 
			-1191, -1192, -1193, -1194, -1195, 
			-1196, -1197, -1198, -1199, -1200, 
			-1201, -1202, -1203, -1204, -1205, 
			-1206, -1207, -1208, -1209, -1252, 
			-1253, -1254, -1255, -1256, -1257, 
			-1258
		) END;