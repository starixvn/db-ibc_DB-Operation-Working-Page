
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssignmentUpload_AllMatchIdsByDateSel] @EventDate DATE
AS

/*
Created: 20200310@Jacob
Task : Assignment Uploading
DB: bodb_OWP

Revisions:
	20200310@Jacob: New structure of Assignment Uploading - [Redmine: #129397]
	20200913@Jacob: Sync Live Status to InfoSite - [Redmine: #134336]
	20200913@Jacob: Sync Live Status to InfoSite - Ignore SABA match - [Redmine: #134336]
*/

     SET NOCOUNT ON;
     DECLARE @EventFromDateTime DATETIME= DATEADD(HOUR, 12, CONVERT(DATETIME, @EventDate));
     DECLARE @EventToDateTime DATETIME= DATEADD(HOUR, 36, CONVERT(DATETIME, @EventDate));

     -- Result
     SELECT m.[OWPMatchId], 
            m.[InfoSiteMatchId],
            CASE
                WHEN l.OWPLeagueName LIKE '%SABA %'
                THEN 1
                ELSE 0
            END IsSaba
     FROM dbo.OWPMatch m WITH(NOLOCK)
          INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
     WHERE m.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime;