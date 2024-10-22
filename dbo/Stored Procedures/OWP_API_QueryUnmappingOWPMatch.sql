
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_API_QueryUnmappingOWPMatch] @FromDate DATE
AS

/*
Created: 20200310@Jacob
Task : Need MatchID column to integrate with AdminSite
DB: bodb_OWP

Revisions:
	20200824@Jacob: Infosite-Link matches between two sites - [Redmine: #140195]   
*/

     SET NOCOUNT ON;
     SELECT m.OWPMatchId, 
            m.EventDateTime, 
            l.OWPLeagueName AS League, 
            h.OWPTeamName AS Home, 
            a.OWPTeamName AS Away
     FROM dbo.OWPMatch m WITH(NOLOCK)
          INNER JOIN OWPTeam h WITH(NOLOCK) ON m.OWPHomeId = h.OWPTeamId
          INNER JOIN OWPTeam a WITH(NOLOCK) ON m.OWPAwayId = a.OWPTeamId
          INNER JOIN OWPLeague l WITH(NOLOCK) ON l.OWPLeagueId = m.OWPLeagueId
     WHERE m.EventDate >= @FromDate
           AND ISNULL(m.InfoSiteMatchId, 0) = 0;