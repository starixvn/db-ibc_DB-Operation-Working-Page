
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TaskListForTodayGet] @UserId              INT, 
                                                @EventDate           DATE, 
                                                @IsGetYesterdayEvent BIT  = 0
AS

/*
 Created: 20161101@Simon.Huynh
 Task : get task list for today
 DB: bodb_OWP

 Revisions:
    20170419@Tim.Trinh: modify trader view time
    20170814@Tim.Trinh: get more info
    20171011@Tim.Trinh: add @ShowAll
	20171213@Quinn.Vo: remove @ShowAll & enhance performance
	20180614@Leo: Display Round/OutSide/Remark independent
	20180723@Raymond.Le: Fix show matchStatus for minorBettype
	20180805@Raymond.Le: Modify follow new structure of event assignment, add params IsGetYesterdayEvent - [Redmine: #92868]
	20190109@Raymond.Le: Rename Provider to Other Provider, Runner to Provider, new structure of MatchOffer - [Redmine: #107257]
	20190116@Kane.Le: Get NoOfHDP Id - [Redmine: #107257]
	20190506@Leo.Vo: Change schema of Provider, OtherProvider, Agent, Television - [Redmine: #112918]
	20190521@Lita.Tang: Add Username value - [Feature: #113765]
	20190715@Carlos.Nguyen: Add maxbetCN88, spreadCN88 - [Readmine: #116798]
	20190815@Kane.Le: Get LastUpdated note - [Feature: #117960]
	20190910@Leo.Vo: Fix issue Fatal error 605 - [Feature: #119987]
	20191024@Kane.Le: Get Provider/Other Provider - [Redmine: #122194]
	20200713@Mira.Nguyen: Apply new time range - [Redmine: #137410]
	20200714@Esther.Nguyen: Build Home Name(N) - [Redmine: #137417]
	20200722@Esther.Nguyen: Ready to Trade Status - [Redmine: #137751]
	20200824@Tyler.Dang: Query trade ready date time - [Redmine: #140194]
	20210128@CarlosNguyen: Query MatchCode - [Redmine: #149347]
	20210128@Esther.Nguyen: Hide Completed Match on Task List - [Redmine: #148228]
	20210906@Luca.Duong: Remove cn88 - [Feature: #160666]
	20211117@Tyler: Filter by EventDate - [Redmine: #164493]
	20220909@Carlos: Copy function - [Redmine: #177317]
	20221216@Johnny: Get Ticket List - [Redmine: #181432]
*/

    BEGIN
        DECLARE @FromTime DATETIME, @ToTime DATETIME;
        DECLARE @str_Completed NVARCHAR(15)= 'Completed'
        -----
        , @Specific15Mins INT= -1, @Specific10Mins INT= -2, @Specific15MinsNoOfCorners INT= -5, @NoOfCorners INT= -3, @NextCorners INT= -4, @LastCorners INT= -90, @HomeSingleTeamCorners INT= -94, @AwaySingleTeamCorners INT= -95, @Specific15MinsTotalBooking INT= -8, @TotalBooking INT= -6, @NextBooking INT= -7, @LastBooking INT= -91, @FastMarket INT= -88, @AllInOne INT= -89, @BettypeHandicap INT= 1, @BettypeLA INT= -1002, @Today DATETIME= GETDATE(), @CurrentDateTime DATETIME= DATEADD(HOUR, 12, GETDATE());
        CREATE TABLE #tblMatchSetting
        (Id             INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED , 
         OWPMatchId     INT, 
         LeagueId       INT, 
         BettypeId      INT, 
         MinorBettypeId INT, 
         ParentMatchId  INT, 
         Maxbet         MONEY, 
         Spread         SMALLMONEY, 
         IsMatchSetting BIT
        );
        CREATE TABLE #tblParentMatchSetting
        (Id             INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED , 
         OWPMatchId     INT, 
         LeagueId       INT, 
         BettypeId      INT, 
         Maxbet         MONEY, 
         Spread         SMALLMONEY, 
         IsMatchSetting BIT
        );
        CREATE TABLE #tblTodayMatch
        (Id                    INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED , 
         OWPMatchId            INT, 
         ParentMatchId         INT, 
         MinorBettypeId        INT, 
         IsMinorMatch          BIT, 
         IsAllowedToViewDetail BIT
        );
        CREATE TABLE #tblNoOfHDPResource
        (Id    INT NOT NULL, 
         Value NVARCHAR(50) NOT NULL
        );
        INSERT INTO #tblNoOfHDPResource
        (Id, 
         Value
        )
               SELECT ResourceId, 
                      Value
               FROM dbo.RefResource WITH(NOLOCK)
               WHERE RefName = 'NoOfHDP';
        SET @FromTime = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00');
        SET @ToTime = DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '11:59:59');

        -- get events can view detail
        INSERT INTO #tblTodayMatch
        (OWPMatchId, 
         ParentMatchId, 
         MinorBettypeId, 
         IsMinorMatch, 
         IsAllowedToViewDetail
        )
               SELECT DISTINCT 
                      om.OWPMatchId, 
                      om.OWPMatchId, 
                      NULL, 
                      0, 
                      1
               FROM dbo.Assignment AS ass WITH(NOLOCK)
                    INNER JOIN dbo.OWPMatch AS om WITH(NOLOCK) ON ass.OWPMatchId = om.OWPMatchId
                    INNER JOIN dbo.MatchInfo AS mi WITH(NOLOCK) ON om.OWPMatchId = mi.OWPMatchId
               WHERE om.EventDateTime BETWEEN @FromTime AND @ToTime
                     AND mi.IsSelected = 1
                     AND ass.UserId = @UserId
                     AND NOT EXISTS
               (
                   SELECT 1
                   FROM dbo.MinorMatch AS mm WITH(NOLOCK)
                   WHERE om.OWPMatchId = mm.MinorMatchId
               )
               UNION
               SELECT DISTINCT 
                      minor.MinorMatchId, 
                      minor.ParentMatchId, 
                      minor.MinorBettypeId, 
                      1, 
                      1
               FROM dbo.Assignment AS ass WITH(NOLOCK)
                    INNER JOIN dbo.OWPMatch AS om WITH(NOLOCK) ON ass.OWPMatchId = om.OWPMatchId
                    INNER JOIN dbo.MatchInfo AS mi WITH(NOLOCK) ON om.OWPMatchId = mi.OWPMatchId
                    INNER JOIN dbo.MinorMatch AS minor WITH(NOLOCK) ON ass.OWPMatchId = minor.MinorMatchId
                    INNER JOIN dbo.MinorBettype AS mib WITH(NOLOCK) ON minor.MinorBettypeId = mib.MinorBettypeId
               WHERE om.EventDateTime BETWEEN @FromTime AND @ToTime
                     AND mi.IsSelected = 1
                     AND minor.IsRepresented = 1
                     AND ass.UserId = @UserId;

        -- insert parent Match of match 10, 15 mins
        INSERT INTO #tblTodayMatch
        (OWPMatchId, 
         ParentMatchId, 
         MinorBettypeId, 
         IsMinorMatch, 
         IsAllowedToViewDetail
        )
               SELECT DISTINCT 
                      mim.ParentMatchId AS OWPMatchId, 
                      mim.ParentMatchId, 
                      NULL, 
                      0, 
                      1 AS IsAllowedToViewDetail
               FROM dbo.MinorMatch AS mim WITH(NOLOCK)
                    INNER JOIN #tblTodayMatch AS tod ON mim.MinorMatchId = tod.OWPMatchId
               WHERE mim.MinorBettypeId IN(@Specific15Mins, @Specific10Mins, @FastMarket, @AllInOne)
                    AND NOT EXISTS
               (
                   SELECT 1
                   FROM #tblTodayMatch
                   WHERE OWPMatchId = mim.ParentMatchId
               );

        -- insert child Match of minor match
        INSERT INTO #tblTodayMatch
        (OWPMatchId, 
         ParentMatchId, 
         MinorBettypeId, 
         IsMinorMatch, 
         IsAllowedToViewDetail
        )
               SELECT om.OWPMatchId, 
                      parent.OWPMatchId, 
                      mm.MinorBettypeId, 
                      1, 
                      mnm.IsAllowedToViewDetail
               FROM
               (
                   SELECT DISTINCT 
                          mim.MinorMatchId AS OWPMatchId, 
                          1 AS IsAllowedToViewDetail
                   FROM dbo.MinorMatch AS mim WITH(NOLOCK)
                        INNER JOIN #tblTodayMatch AS tod ON mim.ParentMatchId = tod.OWPMatchId
                   WHERE mim.MinorBettypeId IN(@Specific15Mins, @Specific10Mins, @FastMarket, @AllInOne)
                        AND NOT EXISTS
                   (
                       SELECT 1
                       FROM #tblTodayMatch
                       WHERE OWPMatchId = mim.MinorMatchId
                   )
                   UNION
                   SELECT DISTINCT 
                          mim1.MinorMatchId AS OWPMatchId, 
                          tod.IsAllowedToViewDetail
                   FROM dbo.MinorMatch AS mim WITH(NOLOCK)
                        INNER JOIN #tblTodayMatch AS tod ON mim.MinorMatchId = tod.OWPMatchId
                        INNER JOIN dbo.MinorMatch AS mim1 WITH(NOLOCK) ON mim1.ParentMatchId = mim.ParentMatchId
                   WHERE NOT EXISTS
                   (
                       SELECT 1
                       FROM #tblTodayMatch
                       WHERE OWPMatchId = mim1.MinorMatchId
                   )
                         AND ((mim.MinorBettypeId = @NoOfCorners
                               AND mim1.MinorBettypeId = @Specific15MinsNoOfCorners)
                              OR (mim.MinorBettypeId = @Specific15MinsNoOfCorners
                                  AND mim1.MinorBettypeId = @NoOfCorners)
                              OR (mim.MinorBettypeId IN(@TotalBooking)
                         AND mim1.MinorBettypeId = @Specific15MinsTotalBooking)
                   OR (mim.MinorBettypeId = @Specific15MinsTotalBooking
                       AND mim1.MinorBettypeId = @TotalBooking))
               ) AS mnm
               INNER JOIN dbo.MinorMatch AS mm WITH(NOLOCK) ON mnm.OWPMatchId = mm.MinorMatchId
               INNER JOIN dbo.OWPMatch AS om WITH(NOLOCK) ON mm.MinorMatchId = om.OWPMatchId
               INNER JOIN dbo.OWPMatch AS parent WITH(NOLOCK) ON mm.ParentMatchId = parent.OWPMatchId;

        -- get match setting
        INSERT INTO #tblMatchSetting
        (OWPMatchId, 
         ParentMatchId, 
         BettypeId, 
         MinorBettypeId, 
         Maxbet, 
         Spread, 
         IsMatchSetting
        )
               SELECT DISTINCT 
                      ml.OWPMatchId, 
                      ml.ParentMatchId, 
                      ms.Bettype, 
                      ml.MinorBettypeId, 
                      ms.Maxbet, 
                      ms.Spread, 
                      1
               FROM #tblTodayMatch AS ml WITH(NOLOCK)
                    INNER JOIN dbo.MatchSetting AS ms WITH(NOLOCK) ON ml.OWPMatchId = ms.OWPMatchId
                                                                      AND (ms.Maxbet IS NOT NULL
                                                                           OR ms.Spread IS NOT NULL);
        INSERT INTO #tblMatchSetting
        (OWPMatchId, 
         ParentMatchId, 
         LeagueId, 
         BettypeId, 
         MinorBettypeId, 
         IsMatchSetting
        )
               SELECT DISTINCT 
                      ml.OWPMatchId, 
                      ml.ParentMatchId, 
                      om.OWPLeagueId AS LeagueId, 
                      ls.Bettype, 
                      ml.MinorBettypeId, 
                      0
               FROM #tblTodayMatch AS ml WITH(NOLOCK)
                    INNER JOIN dbo.OWPMatch AS om WITH(NOLOCK) ON ml.OWPMatchId = om.OWPMatchId
                    INNER JOIN dbo.LeagueSetting AS ls WITH(NOLOCK) ON om.OWPLeagueId = ls.LeagueId
               WHERE ml.IsMinorMatch = 0
                     AND NOT EXISTS
               (
                   SELECT 1
                   FROM #tblMatchSetting AS cms WITH(NOLOCK)
                   WHERE cms.OWPMatchId = ml.OWPMatchId
                         AND cms.BettypeId = ls.Bettype
               );
        UPDATE ms
          SET 
              ms.MaxBet = dbo.OWP_MaxBetGet(ms.OWPMatchId, ms.LeagueId, ms.BettypeId), 
              ms.Spread = dbo.OWP_SpreadGet(ms.OWPMatchId, ms.LeagueId, ms.BettypeId)
        FROM #tblMatchSetting AS ms
        WHERE ms.IsMatchSetting = 0;

        -- parent match setting
        INSERT INTO #tblParentMatchSetting
        (OWPMatchId, 
         BettypeId, 
         Maxbet, 
         Spread, 
         IsMatchSetting
        )
               SELECT DISTINCT 
                      ms.OWPMatchId, 
                      ms.Bettype, 
                      ms.Maxbet, 
                      ms.Spread, 
                      1
               FROM #tblTodayMatch AS ml WITH(NOLOCK)
                    INNER JOIN dbo.MatchSetting AS ms WITH(NOLOCK) ON ml.ParentMatchId = ms.OWPMatchId
                                                                      AND (ms.Maxbet IS NOT NULL
                                                                           OR ms.Spread IS NOT NULL)
               WHERE ml.IsMinorMatch = 1;
        INSERT INTO #tblParentMatchSetting
        (OWPMatchId, 
         LeagueId, 
         BettypeId, 
         IsMatchSetting
        )
               SELECT DISTINCT 
                      parent.OWPMatchId, 
                      parent.OWPLeagueId, 
                      ls.Bettype, 
                      0
               FROM #tblTodayMatch AS ml WITH(NOLOCK)
                    INNER JOIN dbo.OWPMatch AS parent WITH(NOLOCK) ON ml.ParentMatchId = parent.OWPMatchId
                    INNER JOIN dbo.LeagueSetting AS ls WITH(NOLOCK) ON parent.OWPLeagueId = ls.LeagueId
               WHERE ml.IsMinorMatch = 1
                     AND NOT EXISTS
               (
                   SELECT 1
                   FROM #tblParentMatchSetting AS pms WITH(NOLOCK)
                   WHERE pms.OWPMatchId = parent.OWPMatchId
                         AND pms.BettypeId = ls.Bettype
               );
        UPDATE ms
          SET 
              ms.MaxBet = dbo.OWP_MaxBetGet(ms.OWPMatchId, ms.LeagueId, ms.BettypeId), 
              ms.Spread = dbo.OWP_SpreadGet(ms.OWPMatchId, ms.LeagueId, ms.BettypeId)
        FROM #tblParentMatchSetting AS ms
        WHERE ms.IsMatchSetting = 0;

        -- minor setting
        INSERT INTO #tblMatchSetting
        (OWPMatchId, 
         ParentMatchId, 
         BettypeId, 
         MinorBettypeId, 
         Maxbet, 
         Spread
        )
               SELECT tbl.OWPMatchId, 
                      tbl.ParentMatchId, 
                      tbl.InheritedBettypeId, 
                      tbl.MinorBettypeId, 
                      msdt.MaxBet, 
                      msdt.Spread
               FROM
               (
                   SELECT ml.OWPMatchId, 
                          ml.ParentMatchId, 
                          ml.MinorBettypeId, 
                          mbt.ParentBettypeId, 
                          mbt.InheritedBettypeId, 
                          ms.Maxbet
                   FROM #tblTodayMatch AS ml WITH(NOLOCK)
                        INNER JOIN dbo.MinorBettype AS mbt WITH(NOLOCK) ON ml.MinorBettypeId = mbt.ParentBettypeId
                        INNER JOIN #tblParentMatchSetting AS ms WITH(NOLOCK) ON ml.ParentMatchId = ms.OWPMatchId
                                                                                AND ms.BettypeId = @BettypeHandicap
                   WHERE ml.IsMinorMatch = 1
                         AND mbt.InheritedBettypeId <> @BettypeLA
                         AND NOT EXISTS
                   (
                       SELECT 1
                       FROM #tblMatchSetting AS cms WITH(NOLOCK)
                       WHERE cms.OWPMatchId = ml.OWPMatchId
                             AND cms.BettypeId = mbt.InheritedBettypeId
                   )
               ) AS tbl
               INNER JOIN dbo.MinorSetting AS minors WITH(NOLOCK) ON tbl.Maxbet BETWEEN ISNULL(minors.FromMaxBet, 0) AND ISNULL(minors.ToMaxBet, 99999999999)
               INNER JOIN dbo.MinorSettingDetail AS msdt WITH(NOLOCK) ON minors.MinorSettingId = msdt.MinorSettingId
                                                                         AND msdt.MinorBettypeId = tbl.ParentBettypeId;

        -- Return Match Info
        SELECT m.OWPMatchId, 
               m.ParentMatchId, 
               om.EventDate, 
               om.KickOffTime, 
               league.OWPLeagueName AS League,
               CASE
                   WHEN om.IsNeutral = 1
                   THEN home.OWPTeamName + ' (N)'
                   ELSE home.OWPTeamName
               END AS Home, 
               away.OWPTeamName AS Away, 
               om.MatchNo, 
               om.OtherTime, 
               ref.[Value] AS NoOfHDP, 
               inf.NoOfHDPId, 
               inf.[Round], 
               inf.Division, 
               inf.Remark, 
               inf.Phone, 
               inf.WB AS WatchBet, 
               inf.Channel, 
               om.MatchCode, 
			   inf.IPTV,
               STUFF(
        (
            SELECT ', ' + rs.OtherProviderName
            FROM dbo.[OtherProvider] AS rs WITH(NOLOCK)
                 INNER JOIN dbo.MatchOtherProvider AS mop WITH(NOLOCK) ON rs.OtherProviderId = mop.OtherProviderId
            WHERE mop.OWPMatchId = inf.OWPMatchId FOR XML PATH('')
        ), 1, 2, '') AS OtherProvider, 
               STUFF(
        (
            SELECT ', ' + rs.ProviderName
            FROM dbo.[Provider] AS rs WITH(NOLOCK)
                 INNER JOIN dbo.MatchProvider AS mp WITH(NOLOCK) ON rs.ProviderId = mp.ProviderId
            WHERE mp.OWPMatchId = inf.OWPMatchId FOR XML PATH('')
        ), 1, 2, '') AS [Provider], 
               (CASE
                    WHEN DATEDIFF(MINUTE, @CurrentDateTime, om.EventDateTime) <= 60
                    THEN 1
                    WHEN @IsGetYesterdayEvent = 1
                    THEN 1
                    ELSE 0
                END) AS IsOneHourToKickOffTime, 
               [dbo].[OWP_GetCurrentMatchStatus](om.EventDate, om.KickOffTime, inf.MatchStatus) AS MatchStatus, 
               m.MinorBettypeId, 
               m.IsAllowedToViewDetail, 
               (CASE
                    WHEN om.EventDateTime BETWEEN DATEADD(DAY, DATEDIFF(DAY, 0, @Today), '12:00:00') AND DATEADD(DAY, DATEDIFF(DAY, -1, @Today), '11:59:59')
                    THEN 1
                    ELSE 0
                END) AS IsTodayEvent, 
               (CASE
                    WHEN rd.UserId = @UserId
                         AND rd.MatchId = m.OWPMatchId
                    THEN 1
                    ELSE 0
                END) AS IsReady, 
               rd.ReadyDateTime AS ReadyDateTime, 
               (CASE
                    WHEN maindb.eventstatus = @str_Completed
                    THEN 1
                    ELSE 0
                END) AS IsCompletedMatch
        FROM #tblTodayMatch AS m WITH(NOLOCK)
             INNER JOIN dbo.OWPMatch AS om WITH(NOLOCK) ON m.OWPMatchId = om.OWPMatchId
             INNER JOIN dbo.OWPMatch AS pa WITH(NOLOCK) ON m.ParentMatchId = pa.OWPMatchId
             INNER JOIN dbo.MatchInfo AS inf WITH(NOLOCK) ON m.OWPMatchId = inf.OWPMatchId
             INNER JOIN dbo.MatchInfo AS painf WITH(NOLOCK) ON m.ParentMatchId = painf.OWPMatchId
             INNER JOIN dbo.OWPLeague AS league WITH(NOLOCK) ON om.OWPLeagueId = league.OWPLeagueId
             INNER JOIN dbo.OWPTeam AS home WITH(NOLOCK) ON om.OWPHomeId = home.OWPTeamId
             INNER JOIN dbo.OWPTeam AS away WITH(NOLOCK) ON om.OWPAwayId = away.OWPTeamId
             LEFT JOIN #tblNoOfHDPResource AS ref WITH(NOLOCK) ON inf.NoOfHDPId = ref.Id
			 LEFT JOIN dbo.InfoSiteMatch AS im WITH(NOLOCK) ON om.InfoSiteMatchId = im.InfoSiteMatchId
             LEFT JOIN bodb02.dbo.match AS maindb WITH(NOLOCK) ON maindb.matchid = im.AdminSiteMatchId
             LEFT JOIN dbo.ReadyTradeStatus AS rd WITH(NOLOCK) ON m.OWPMatchId = rd.MatchId
                                                                  AND rd.UserId = @UserId
        WHERE m.MinorBettypeId NOT IN(@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
             OR m.MinorBettypeId IS NULL
        ORDER BY om.EventDate, 
                 om.KickOffTime,
                 CASE
                     WHEN ISNULL(om.MatchNo, '') = ''
                     THEN 1
                     ELSE 0
                 END, 
                 om.MatchNo;

        -- Return Assignment
        SELECT OWPMatchId, 
               ParentMatchId, 
               BettypeId, 
               MinorBettypeId, 
               UserId, 
               IsCurrentUser, 
               Username, 
               Skype, 
               Extension, 
               Phone, 
               AssignmentType, 
               AssignmentNote, 
               IsCancelled
        FROM
        (
            SELECT a.OWPMatchId, 
                   ml.ParentMatchId, 
                   a.Bettype AS BettypeId, 
                   ml.MinorBettypeId, 
                   a.UserId, 
                   (CASE
                        WHEN a.UserId = @UserId
                        THEN 1
                        ELSE 0
                    END) AS IsCurrentUser, 
                   u.Username, 
                   u.Nickname, 
                   u.Skype, 
                   u.Extension, 
                   u.Phone, 
                   a.AssignmentType, 
                   a.AssignmentNote, 
                   a.AssignmentId, 
                   (CASE
                        WHEN btc.OWPMatchId IS NULL
                        THEN 0
                        ELSE 1
                    END) IsCancelled
            FROM dbo.Assignment AS a WITH(NOLOCK)
                 INNER JOIN dbo.MajorBettype AS bt WITH(NOLOCK) ON a.Bettype = bt.BettypeId
                 INNER JOIN #tblTodayMatch AS ml WITH(NOLOCK) ON a.OWPMatchId = ml.OWPMatchId
                 LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
                 LEFT JOIN dbo.MatchBetypeCancel AS btc WITH(NOLOCK) ON btc.OWPMatchId = ml.OWPMatchId
                                                                        AND btc.BetType = a.Bettype
                 LEFT JOIN dbo.MinorBettype AS mbt WITH(NOLOCK) ON ml.MinorBettypeId = mbt.ParentBettypeId
                                                                   AND a.Bettype = mbt.InheritedBettypeId
            WHERE(ml.IsMinorMatch = 0
                  OR (ml.IsMinorMatch = 1
                      AND mbt.MinorBettypeId IS NOT NULL
                      AND ml.MinorBettypeId NOT IN(@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)))
            UNION
            SELECT a.OWPMatchId, 
                   ml.ParentMatchId, 
                   a.Bettype AS BettypeId, 
                   mbt.ParentBettypeId, 
                   a.UserId, 
                   (CASE
                        WHEN a.UserId = @UserId
                        THEN 1
                        ELSE 0
                    END) AS IsCurrentUser, 
                   u.Username, 
                   u.Nickname, 
                   u.Skype, 
                   u.Extension, 
                   u.Phone, 
                   a.AssignmentType, 
                   a.AssignmentNote, 
                   a.AssignmentId, 
                   (CASE
                        WHEN btc.OWPMatchId IS NULL
                        THEN 0
                        ELSE 1
                    END) IsCancelled
            FROM dbo.Assignment AS a WITH(NOLOCK)
                 INNER JOIN dbo.MinorMatch AS minor WITH(NOLOCK) ON a.OWPMatchId = minor.MinorMatchId
                 INNER JOIN dbo.MajorBettype AS bt WITH(NOLOCK) ON a.Bettype = bt.BettypeId
                 INNER JOIN #tblTodayMatch AS ml WITH(NOLOCK) ON minor.ParentMatchId = ml.OWPMatchId
                                                                 AND ml.IsMinorMatch = 0
                 LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
                 INNER JOIN dbo.MinorBettype AS mbt WITH(NOLOCK) ON minor.MinorBettypeId = mbt.ParentBettypeId
                                                                    AND a.Bettype = mbt.InheritedBettypeId
                                                                    AND mbt.ParentBettypeId IN(@Specific10Mins, @Specific15Mins, @FastMarket, @AllInOne)
                 LEFT JOIN dbo.MatchBetypeCancel AS btc WITH(NOLOCK) ON btc.OWPMatchId = minor.MinorMatchId
                                                                        AND btc.BetType = a.Bettype
            WHERE a.Bettype IN(@BettypeHandicap, @BettypeLA)
            UNION
            SELECT a.OWPMatchId, 
                   ml.ParentMatchId, 
                   a.Bettype AS BettypeId, 
                   mbt.ParentBettypeId, 
                   a.UserId, 
                   (CASE
                        WHEN a.UserId = @UserId
                        THEN 1
                        ELSE 0
                    END) AS IsCurrentUser, 
                   u.Username, 
                   u.Nickname, 
                   u.Skype, 
                   u.Extension, 
                   u.Phone, 
                   a.AssignmentType, 
                   a.AssignmentNote, 
                   a.AssignmentId, 
                   (CASE
                        WHEN btc.OWPMatchId IS NULL
                        THEN 0
                        ELSE 1
                    END) IsCancelled
            FROM dbo.Assignment AS a WITH(NOLOCK)
                 INNER JOIN dbo.MinorMatch AS minor WITH(NOLOCK) ON a.OWPMatchId = minor.MinorMatchId
                 INNER JOIN dbo.MajorBettype AS bt WITH(NOLOCK) ON a.Bettype = bt.BettypeId
                 INNER JOIN #tblTodayMatch AS ml WITH(NOLOCK) ON minor.ParentMatchId = ml.ParentMatchId
                                                                 AND ml.IsMinorMatch = 1
                                                                 AND ml.MinorBettypeId IN(@NoOfCorners, @TotalBooking)
                 LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
                 INNER JOIN dbo.MinorBettype AS mbt WITH(NOLOCK) ON minor.MinorBettypeId = mbt.ParentBettypeId
                                                                    AND a.Bettype = mbt.InheritedBettypeId
                                                                    AND mbt.ParentBettypeId IN(@Specific15MinsNoOfCorners, @Specific15MinsTotalBooking)
                 LEFT JOIN dbo.MatchBetypeCancel AS btc WITH(NOLOCK) ON btc.OWPMatchId = minor.MinorMatchId
                                                                        AND btc.BetType = a.Bettype
            WHERE a.Bettype IN(@BettypeHandicap, @BettypeLA)
        ) AS am
        ORDER BY am.AssignmentId;

        -- Return Match Setting
        SELECT OWPMatchId, 
               ParentMatchId, 
               BettypeId, 
               MinorBettypeId, 
               Maxbet, 
               Spread
        FROM #tblMatchSetting WITH(NOLOCK);

        -- Return Match Notes
        DECLARE @TimeZoneGMT8 INT= 8;
        SELECT mn.OWPMatchId, 
               u.Username, 
               mn.Note, 
               (CASE
                    WHEN mnu.IsViewed IS NULL
                         OR mnu.IsViewed = 0
                    THEN 0
                    ELSE 1
                END) AS IsViewed, 
               DATEADD(HH, @TimeZoneGMT8, (DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), mn.CreatedDate))) AS LastUpdated
        FROM dbo.MatchNote AS mn WITH(NOLOCK)
             INNER JOIN #tblTodayMatch AS ml WITH(NOLOCK) ON mn.OWPMatchId = ml.OWPMatchId
             LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON mn.CreatedBy = u.UserId
             LEFT JOIN dbo.MatchNoteUser AS mnu WITH(NOLOCK) ON mn.MatchNoteId = mnu.MatchNoteId
                                                                AND mnu.UserId = @UserId
        WHERE ml.MinorBettypeId NOT IN(@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
             OR ml.MinorBettypeId IS NULL
        ORDER BY(CASE
                     WHEN mnu.IsViewed IS NULL
                          OR mnu.IsViewed = 0
                     THEN 0
                     ELSE 1
                 END) ASC, 
                mn.CreatedDate DESC;

        -- Return TV color
        SELECT ml.OWPMatchId, 
               tv.TVCode, 
               tv.Color
        FROM #tblTodayMatch AS ml WITH(NOLOCK)
             INNER JOIN dbo.MatchInfo AS info WITH(NOLOCK) ON ml.OWPMatchId = info.OWPMatchId
             INNER JOIN dbo.MatchTelevision AS mt WITH(NOLOCK) ON mt.OWPMatchId = info.OWPMatchId
             INNER JOIN dbo.Television AS tv WITH(NOLOCK) ON mt.TVId = tv.TVId
        ORDER BY tv.TVId;

        -- Retunr Match Offer
        SELECT tm.OWPMatchId, 
               rr.[Value] AS MatchOfferValue
        FROM #tblTodayMatch AS tm WITH(NOLOCK)
             INNER JOIN dbo.MatchOfferDetail AS mo WITH(NOLOCK) ON tm.OWPMatchId = mo.OWPMatchId
             LEFT JOIN dbo.RefResource AS rr WITH(NOLOCK) ON mo.MatchOfferId = rr.ResourceId
        WHERE rr.RefName = 'MatchOffer';

        SELECT DISTINCT 
               om.OWPMatchId, 
               (CASE
                    WHEN maindb.eventstatus = @str_Completed
                    THEN 1
                    ELSE 0
                END) AS IsCompletedMatch
        FROM dbo.OWPMatch AS om WITH(NOLOCK)
             INNER JOIN #tblTodayMatch AS m WITH(NOLOCK) ON m.ParentMatchId = om.OWPMatchId
			 LEFT JOIN dbo.InfoSiteMatch AS im WITH(NOLOCK) ON om.InfoSiteMatchId = im.InfoSiteMatchId
             LEFT JOIN bodb02.dbo.match AS maindb WITH(NOLOCK) ON maindb.matchid = im.AdminSiteMatchId;
		
		--return TicketInfo 

        SELECT DISTINCT 
               x.TicketId,
               CASE
                   WHEN u.Nickname IS NULL
                   THEN u.Username
                   ELSE u.Nickname
               END AS LatestUsername, 
               tm.CreatedDate AS LatestCreatedDate, 
               tm.[Message] AS LatestMessage, 
               reader.IsRead, 
               ts.SubtypeId, 
               ts.SubtypeName, 
               x.OWPMatchId
        FROM
        (
            SELECT te.TicketId, 
                   MAX(tm.Id) MaxId, 
                   ti.SubtypeId, 
                   tbl.OWPMatchId
            FROM dbo.TicketIssueLiveIncident AS te WITH(NOLOCK)
                 INNER JOIN #tblTodayMatch AS tbl ON tbl.OWPMatchId = te.OwpMatchId
                 INNER JOIN dbo.TicketIssue ti WITH(NOLOCK) ON ti.TicketId = te.TicketId
                 LEFT JOIN dbo.TicketMessage AS tm WITH(NOLOCK) ON ti.TicketId = tm.TicketId
            GROUP BY te.TicketId, 
                     ti.SubtypeId, 
                     tbl.OWPMatchId
        ) AS x
        LEFT JOIN dbo.TicketMessage AS tm WITH(NOLOCK) ON tm.TicketId = x.TicketId
        INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON tm.UserId = u.UserId
        INNER JOIN dbo.TicketMessageReader AS reader WITH(NOLOCK) ON x.TicketId = reader.TicketId
                                                                     AND reader.RecipientId = @UserId
        LEFT JOIN dbo.TicketSubtype AS ts WITH(NOLOCK) ON ts.SubtypeId = x.SubtypeId
        WHERE tm.Id = x.MaxId
        ORDER BY tm.CreatedDate DESC;

        DROP TABLE #tblTodayMatch;
        DROP TABLE #tblMatchSetting;
        DROP TABLE #tblParentMatchSetting;
        DROP TABLE #tblNoOfHDPResource;
    END;