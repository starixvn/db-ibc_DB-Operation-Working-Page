
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssginmentUpload_AllMatchSettingsByDateSel] @EventDate DATE
AS

/*
Created: 20200310@Jacob
Task : Assignment Uploading
DB: bodb_OWP

Revisions:
	20200310@Jacob: New structure of Assignment Uploading - [Redmine: #129397]
	
*/

     SET NOCOUNT ON;
     DECLARE @EventFromDateTime DATETIME= DATEADD(HOUR, 12, CONVERT(DATETIME, @EventDate));
     DECLARE @EventToDateTime DATETIME= DATEADD(HOUR, 36, CONVERT(DATETIME, @EventDate));

     -- Result
     SELECT s.[OWPMatchId] MatchId, 
            [Bettype], 
            [Spread], 
            [Maxbet], 
            [MaxbetCN88], 
            [SpreadCN88]
     FROM [dbo].[MatchSetting] s WITH(NOLOCK)
          INNER JOIN dbo.OWPMatch m WITH(NOLOCK) ON m.OWPMatchId = s.OWPMatchId
     WHERE m.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime
           AND EXISTS
     (
         SELECT 1
         FROM Assignment s WITH(NOLOCK)
         WHERE s.OWPMatchId = m.OWPMatchId
     );