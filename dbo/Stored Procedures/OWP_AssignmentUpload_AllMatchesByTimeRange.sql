
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssignmentUpload_AllMatchesByTimeRange] @EventDate DATE
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
                  AND ((mm.MinorBettypeId IS NOT NULL AND mm.MinorBettypeId IN(-3, -4, -6, -7, -90, -91, -94, -95)
                  AND m.EventDateTime BETWEEN @FromTimeSendMessageSpecialBettype AND @ToTimeSendMessageSpecialBettype)
            OR (mm.MinorBettypeId IS NULL OR mm.MinorBettypeId NOT IN(-3, -4, -6, -7, -90, -91, -94, -95)
                 AND m.EventDateTime BETWEEN @FromTimeSendMessage AND @ToTimeSendMessage));
     -- Result
     SELECT m.[OWPMatchId] AS MatchId, 
            m.[InfoSiteMatchId], 
            mm.[ParentMatchId] AS ParentMatchId, 
            mm.[MinorBettypeId] AS MatchType, 
            mb.[MinorBettypeName] AS MinorBettypeName, 
            l.[OWPLeagueName] AS LeagueName, 
            h.[OWPTeamName] AS Home, 
            a.[OWPTeamName] AS Away, 
            m.[EventDate], 
            m.[EventDateTime], 
            m.[OtherTime], 
            m.[KickOffTime], 
            STUFF(
     (
         SELECT ', ' + an.AgentName
         FROM dbo.Agent AS an WITH(NOLOCK)
              INNER JOIN dbo.MatchAgent AS ma WITH(NOLOCK) ON an.AgentId = ma.AgentId
         WHERE ma.OWPMatchId = m.OWPMatchId FOR XML PATH('')
     ), 1, 2, '') AS Agent, 
            i.[Channel], 
            i.[Division], 
            m.[MatchNo], 
            STUFF(
     (
         SELECT ', ' + [Value]
         FROM dbo.[RefResource] WITH(NOLOCK)
              INNER JOIN dbo.MatchOfferDetail mo WITH(NOLOCK) ON mo.MatchOfferId = ResourceId
                                                                 AND RefName = 'MatchOffer'
         WHERE mo.OWPMatchId = m.OWPMatchId FOR XML PATH('')
     ), 1, 2, '') AS MatchOffer, 
            i.[MatchStatus], 
            hdp.[Value] AS NoOfHDP, 
            STUFF(
     (
         SELECT ', ' + mn.Note
         FROM dbo.MatchNote mn WITH(NOLOCK)
         WHERE mn.OWPMatchId = m.OWPMatchId FOR XML PATH('')
     ), 1, 2, '') AS Note, 
            i.[Phone], 
            STUFF(
     (
         SELECT ', ' + p.ProviderName
         FROM dbo.[Provider] p WITH(NOLOCK)
              INNER JOIN dbo.MatchProvider mp WITH(NOLOCK) ON p.ProviderId = mp.ProviderId
         WHERE mp.OWPMatchId = m.OWPMatchId FOR XML PATH('')
     ), 1, 2, '') AS [Provider], 
            STUFF(
     (
         SELECT ', ' + p.OtherProviderName
         FROM dbo.[OtherProvider] p WITH(NOLOCK)
              INNER JOIN dbo.MatchOtherProvider mp WITH(NOLOCK) ON p.OtherProviderId = mp.OtherProviderId
         WHERE mp.OWPMatchId = m.OWPMatchId FOR XML PATH('')
     ), 1, 2, '') AS [OtherProvider], 
            i.[Remark], 
            i.[Round], 
            STUFF(
     (
         SELECT ', ' + p.TVCode
         FROM dbo.Television p WITH(NOLOCK)
              INNER JOIN dbo.MatchTelevision mp WITH(NOLOCK) ON p.TVId = mp.TVId
         WHERE mp.OWPMatchId = m.OWPMatchId FOR XML PATH('')
     ), 1, 2, '') AS [TV], 
            i.[WB], 
            i.[Website1], 
            i.[Website2], 
            i.[Website3], 
            i.[Website4]
     FROM dbo.OWPMatch m WITH(NOLOCK)
          LEFT JOIN dbo.MinorMatch mm WITH(NOLOCK) ON m.OWPMatchId = mm.MinorMatchId
          LEFT JOIN dbo.MinorBettype mb WITH(NOLOCK) ON mm.MinorBettypeId = mb.MinorBettypeId
          INNER JOIN dbo.OWPTeam h WITH(NOLOCK) ON m.OWPHomeId = h.OWPTeamId
          INNER JOIN dbo.OWPTeam a WITH(NOLOCK) ON m.OWPAwayId = a.OWPTeamId
          INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
          LEFT JOIN dbo.MatchInfo i WITH(NOLOCK) ON m.OWPMatchId = i.OWPMatchId
          LEFT JOIN dbo.RefResource hdp WITH(NOLOCK) ON i.NoOfHDPId = hdp.ResourceId
                                                        AND hdp.RefName = 'NoOfHDP'
          INNER JOIN @MatchInTimeRange mt ON m.OWPMatchId = mt.OWPMatchId