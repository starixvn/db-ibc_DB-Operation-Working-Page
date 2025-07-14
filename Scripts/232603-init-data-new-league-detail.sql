/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250714@Frankie
Task : Init data for new league detail
DB: bodb_OWP	

Revisions:
	20250714@Frankie: Init data for new league detail - [Redmine: #232603]
*/

DECLARE @TimeZoneGMT8 INT = 8;
DECLARE @Today DATE = DATEADD(HOUR, @TimeZoneGMT8 - DATEDIFF(HOUR, GETUTCDATE(), GETDATE()), GETDATE());

INSERT INTO LeagueManagementSetting (OWPLeagueId)
SELECT owpl.OWPLeagueId
FROM OWPLeague AS owpl WITH (NOLOCK)
	LEFT JOIN LeagueCategoryHistory AS lch WITH (NOLOCK)
		ON owpl.OWPLeagueId = lch.OWPLeagueId
			AND @Today >= lch.StartDate
			AND (@Today <= lch.EndDate OR lch.EndDate IS NULL)
WHERE lch.CategoryId IS NOT NULL
	AND owpl.IsActive = 1
	AND NOT EXISTS (
		SELECT 1
		FROM LeagueManagementSetting AS lms WITH (NOLOCK)
		WHERE lms.OWPLeagueId = owpl.OWPLeagueId
	);





