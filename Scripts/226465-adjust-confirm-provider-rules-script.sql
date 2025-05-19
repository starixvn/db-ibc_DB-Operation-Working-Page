/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250516@Lilac
Task : Provider Verification
DB: bodb_OWP

Revisions:
	20250516@Lilac: Update confirm provider to cancel if the match is from SABA and the status is cancel. [Redmine: #213719]
*/

UPDATE t
SET t.AgentId = 12 -- Cancel
FROM MatchAgentConfirm t
INNER JOIN dbo.OWPMatch m WITH(NOLOCK) ON m.OWPMatchId = t.OWPMatchId
INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
LEFT JOIN dbo.MatchInfo i WITH(NOLOCK) ON m.OWPMatchId = i.OWPMatchId
WHERE i.MatchStatus LIKE 'Cancel' AND l.OWPLeagueName LIKE '%SABA %'
AND m.EventDate BETWEEN '2025-05-01' AND '2025-05-19' AND t.AgentId <> 12
