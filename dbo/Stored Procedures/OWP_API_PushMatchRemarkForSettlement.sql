
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_API_PushMatchRemarkForSettlement] 

AS

/*
Created: 20250908@Frankie
Task : API Integration - Support pushing Match Information and "Remark" for Settlement
DB: bodb_OWP	

Revisions:
	20250908@Frankie: Init SP - Redmine: #237534
*/

BEGIN
	SET NOCOUNT ON;
	DECLARE @NowUTC8 DATETIME = DATEADD(HOUR, 8, GETUTCDATE());

	DECLARE @BizDate DATE = CASE 
								WHEN CAST(@NowUTC8 AS TIME) < '12:00:00'
									THEN DATEADD(DAY, -1, CAST(@NowUTC8 AS DATE))
								ELSE CAST(@NowUTC8 AS DATE)
							END;

	DECLARE @FromDate DATETIME = DATEADD(HOUR, 12, DATEADD(DAY, -1, CAST(@BizDate AS DATETIME)));
	DECLARE @ToDate   DATETIME = DATEADD(SECOND, -1, DATEADD(HOUR, 12, DATEADD(DAY, 3, CAST(@BizDate AS DATETIME))));

	WITH Base AS (
		SELECT om.OWPMatchId, 
				om.EventDateTime,
				mi.Remark, 
				minor.MinorBettypeId,
				CASE 
					WHEN minor.MinorBettypeId IS NULL THEN NULL
					ELSE ISNULL(map.SubType, 0)
				END AS SubType,
				im.AdminSiteMatchId AS ParentAdminSiteId,
				COALESCE(minor.ParentMatchId, om.OWPMatchId) AS ParentMatchId
		FROM dbo.OWPMatch om WITH(NOLOCK)
				INNER JOIN dbo.MatchInfo mi WITH(NOLOCK) ON om.OWPMatchId = mi.OWPMatchId
				LEFT JOIN dbo.MinorMatch minor WITH(NOLOCK) ON om.OWPMatchId = minor.MinorMatchId
				LEFT JOIN dbo.OWPMatch pm WITH(NOLOCK) ON pm.OWPMatchId = COALESCE(minor.ParentMatchId, om.OWPMatchId)
				LEFT JOIN dbo.InfoSiteMatch im WITH(NOLOCK) ON im.InfoSiteMatchId = pm.InfoSiteMatchId
				LEFT JOIN (
					VALUES 
					(-1, 1800), (-2, 1900), (-3, 2000), 
					(-4, 2101), (-5, 2700), (-6, 2800), 
					(-7, 2901), (-8, 3500), 
					(-11, 1200), (-14, 600), (-15, 800), 
					(-90, 2300), (-91, 3100), (-92, 1601), (-93, 1602), 
					(-94, 2401), (-95, 2402), (-96, 5800), (-97, 5700), 
					(-98, 1100), (-99, 1150), 
					(-100, 3900), (-101, 4100), (-102, 4000), 
					(-103, 4600), (-104, 4500), (-105, 4900), 
					(-106, 4800), (-107, 5400), (-108, 5300), 
					(-109, 400)
				) AS map(MinorBettypeId, SubType)
				ON minor.MinorBettypeId = map.MinorBettypeId
		WHERE om.EventDateTime BETWEEN @FromDate AND @ToDate
				AND mi.IsSelected = 1
				AND mi.Remark <> ''
				AND (minor.IsRepresented = 1 OR minor.IsRepresented IS NULL)
	),

	Unioned AS (
		-- Phần 1: SubType NULL hoặc 0
		SELECT 
			b.OWPMatchId,
			b.EventDateTime,
			b.Remark,
			b.MinorBettypeId,
			b.SubType,
			b.ParentAdminSiteId,
			CASE 
				WHEN b.SubType IS NULL THEN b.ParentAdminSiteId
				WHEN b.SubType = 0 THEN NULL
			END AS AdminSiteId
		FROM Base b
		WHERE b.SubType IS NULL OR b.SubType = 0

		UNION ALL

		-- Phần 2: SubType khác NULL và khác 0
		SELECT 
			b.OWPMatchId,
			b.EventDateTime,
			b.Remark,
			b.MinorBettypeId,
			b.SubType,
			b.ParentAdminSiteId,
			ms.MatchId AS AdminSiteId
		FROM Base b
				INNER JOIN (
					SELECT m.ParentID, mr.SubType, m.MatchId
					FROM bodb02.dbo.[match] m
						INNER JOIN bodb02.dbo.match_remark mr WITH(NOLOCK) 
							ON m.MatchId = mr.MatchId
					WHERE m.IsDeleted = 0
				) ms
					ON ms.ParentID = b.ParentAdminSiteId
				AND ms.SubType = b.SubType
		WHERE b.SubType IS NOT NULL AND b.SubType <> 0
	)
	SELECT *
	FROM Unioned
	WHERE AdminSiteId IS NOT NULL AND AdminSiteId <> 0;

END;