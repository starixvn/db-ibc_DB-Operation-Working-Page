
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssignmentUpload_AllMatchSettingsByTimeRange] @EventDate DATE
AS

/*
Created: 20200310@Jacob
Task : Assignment Uploading
DB: bodb_OWP

Revisions:
	20200310@Jacob: New structure of Assignment Uploading - [Redmine: #129397]
	20200713@Mira.Nguyen: Apply new time range - [Redmine: #137410]
	20210906@Luca.Duong: Remove cn88 - [Feature: #160666]
*/

     SET NOCOUNT ON;
     DECLARE @EventFromDateTime DATETIME= DATEADD(HOUR, 12, CONVERT(DATETIME, @EventDate));
     DECLARE @EventToDateTime DATETIME= DATEADD(HOUR, 36, CONVERT(DATETIME, @EventDate));
     -- Time Range
     DECLARE @FromTimeSendMessage DATETIME, @ToTimeSendMessage DATETIME;
	 
     SELECT @FromTimeSendMessage = FromTime, 
            @ToTimeSendMessage = ToTime
     FROM dbo.fnc_GetDateTimeForTraderViewTime();

     -- Result
     SELECT s.[OWPMatchId] MatchId, 
            [Bettype], 
            [Spread], 
            [Maxbet], 
     FROM [dbo].[MatchSetting] s WITH(NOLOCK)
          INNER JOIN dbo.OWPMatch m WITH(NOLOCK) ON m.OWPMatchId = s.OWPMatchId
          LEFT JOIN dbo.MatchInfo i WITH(NOLOCK) ON m.OWPMatchId = i.OWPMatchId
	 WHERE i.IsSelected = 1
           AND m.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime
           AND m.EventDateTime BETWEEN @FromTimeSendMessage AND @ToTimeSendMessage		  