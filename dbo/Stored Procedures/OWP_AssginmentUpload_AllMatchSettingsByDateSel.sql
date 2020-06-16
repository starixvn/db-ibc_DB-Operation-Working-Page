
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
	 -- Time Range
     DECLARE @FromTimeSendMessage DATETIME, @ToTimeSendMessage DATETIME, @FromTimeSendMessageSpecialBettype DATETIME, @ToTimeSendMessageSpecialBettype DATETIME;

     -- Bettypes Corner & Booking but not 15 mins: -3, -4, -6, -7, -90, -91, -94, -95
     SELECT @FromTimeSendMessage = FromTime, 
            @ToTimeSendMessage = ToTime, 
            @FromTimeSendMessageSpecialBettype = FromTimeForSpecialBettype, 
            @ToTimeSendMessageSpecialBettype = ToTimeForSpecialBettype
     FROM dbo.fnc_GetDateTimeForTraderViewTime();
     DECLARE @MatchInTimeRange TABLE(OWPMatchId INT);
     INSERT INTO @MatchInTimeRange
            SELECT m.OWPMatchId
            FROM dbo.OWPMatch m WITH(NOLOCK)
                 INNER JOIN dbo.MatchInfo mi WITH(NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
                 LEFT JOIN dbo.MinorMatch mm WITH(NOLOCK) ON m.OWPMatchId = mm.MinorMatchId
            WHERE mi.IsSelected = 1
                  AND m.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime
                  AND ((mm.MinorBettypeId IN(-3, -4, -6, -7, -90, -91, -94, -95)
                  AND m.EventDateTime BETWEEN @FromTimeSendMessageSpecialBettype AND @ToTimeSendMessageSpecialBettype)
            OR (mm.MinorBettypeId NOT IN(-3, -4, -6, -7, -90, -91, -94, -95)
                 AND m.EventDateTime BETWEEN @FromTimeSendMessage AND @ToTimeSendMessage));
     -- Result
     SELECT s.[OWPMatchId] MatchId, 
            [Bettype], 
            [Spread], 
            [Maxbet], 
            [MaxbetCN88], 
            [SpreadCN88]
     FROM [dbo].[MatchSetting] s WITH(NOLOCK)
          INNER JOIN dbo.OWPMatch m WITH(NOLOCK) ON m.OWPMatchId = s.OWPMatchId
		  INNER JOIN @MatchInTimeRange mt ON m.OWPMatchId = mt.OWPMatchId
     WHERE EXISTS
     (
         SELECT 1
         FROM Assignment s WITH(NOLOCK)
         WHERE s.OWPMatchId = m.OWPMatchId
     );