/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

/*
Created: 20251117@Frankie
Task : Init no offer for league setting
DB: bodb_OWP

Revisions:
	20251117@Frankie: Init no offer for league setting - [Redmine: #242201]
*/
USE bodb_OWP;
GO

UPDATE l
SET l.NoOfferLive = 1
FROM LeagueManagementSetting l WITH (NOLOCK)
INNER JOIN OWPLeague o WITH (NOLOCK)
    ON l.OWPLeagueId = o.OWPLeagueId
WHERE o.NoOfferLive = 1;