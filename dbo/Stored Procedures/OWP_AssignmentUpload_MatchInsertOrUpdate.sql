
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssignmentUpload_MatchInsertOrUpdate] @Assignments NVARCHAR(MAX), 
                                                                 @EventDate   DATE, 
                                                                 @UserId      INT
AS

/*
Created: 20200310@Jacob
Task : Assignment Uploading
DB: bodb_OWP

Revisions:
	20200310@Jacob: New structure of Assignment Uploading - [Redmine: #129397]
	20200713@Esther.Nguyen: Importing match in Neutral Stadium - [Redmine: #137417]
	20200730@Jack.Nguyen: add IPTV, AdminSiteId, changeName MachId  - [Redmine: #137756]
	20200901@Mira.Nguyen: Notification when re-uploading match with Neutral [Redmine: #140807]
	20201109@Carlos.Nguyen: LA Auto Assignment - Determine ET/PK match - [Redmine: #144570]
	20200128@Mira: Saba match validation rule - [Redmine: 149472]
	20240131@Los: Fix not save other time at 12AM - [Redmine: 200529]
*/

     SET NOCOUNT ON;
     DECLARE @EventFromDateTime DATETIME= DATEADD(HOUR, 12, CAST(@EventDate AS DATETIME));
     DECLARE @EventToDateTime DATETIME= DATEADD(DAY, 1, @EventFromDateTime);
     CREATE TABLE #tmpTable
     (MinorBettypeId  INT, 
      HashKey         VARCHAR(200), 
      IsSaba          BIT, 
      InfoSiteMatchId INT, 
      AdminSiteId     INT, 
      League          NVARCHAR(500), 
      Home            NVARCHAR(200), 
      Away            NVARCHAR(200), 
      EventDate       DATETIME, 
      MatchNo         VARCHAR(50), 
      OtherTime       TIME(7), 
      KickOffTime     TIME(7), 
      Channel         NVARCHAR(100), 
      IPTV            NVARCHAR(100), 
      Division        NVARCHAR(2000), 
      MatchOffer      NVARCHAR(100), 
      MatchStatus     VARCHAR(15), 
      NoHDP           VARCHAR(50), 
      Phone           NVARCHAR(200), 
      Remark          NVARCHAR(2000), 
      [Round]         NVARCHAR(2000), 
      WB              NVARCHAR(100), 
      Website1        NVARCHAR(1000), 
      Website2        NVARCHAR(1000), 
      Website3        NVARCHAR(1000), 
      Website4        NVARCHAR(1000), 
      ParentHashKey   VARCHAR(200), 
      IsNeutral       BIT, 
      HomeId          INT, 
      AwayId          INT, 
      LeagueId        INT, 
      OWPMatchId      INT, 
      ETPK            NVARCHAR(2000)
     );
     DECLARE @idoc INT;
     EXEC sp_xml_preparedocument 
          @idoc OUTPUT, 
          @Assignments;
     INSERT INTO #tmpTable
            SELECT DISTINCT 
                   ISNULL(MinorBettypeId, 0), 
                   HashKey, 
                   IsSaba BIT, 
                   NULLIF(InfoSiteMatchId, 0), 
                   NULLIF(AdminSiteId, 0), 
                   League, 
                   Home, 
                   Away, 
                   EventDate, 
                   MatchNo, 
                   NULLIF((OtherTime), ''), 
                   KickOffTime, 
                   Channel, 
                   IPTV, 
                   Division, 
                   MatchOffer, 
                   MatchStatus, 
                   NoHDP, 
                   Phone, 
                   Remark, 
                   [Round], 
                   WB, 
                   Website1, 
                   Website2, 
                   Website3, 
                   Website4, 
                   ParentHashKey, 
                   IsNeutral, 
                   0, 
                   0, 
                   0, 
                   0, 
                   EtPk
            FROM OPENXML(@idoc, '/Root/AssignmentModel', 1) WITH(HashKey VARCHAR(200), IsSaba BIT, InfoSiteMatchId INT, AdminSiteId INT, League NVARCHAR(500), Home NVARCHAR(200), Away NVARCHAR(200), EventDate DATETIME, MatchNo VARCHAR(50), OtherTime NVARCHAR(7), KickOffTime TIME(7), Channel NVARCHAR(100), IPTV NVARCHAR(100), Division NVARCHAR(2000), MatchOffer NVARCHAR(100), MatchStatus VARCHAR(15), NoHDP VARCHAR(50), Phone NVARCHAR(200), Remark NVARCHAR(2000), [Round] NVARCHAR(2000), WB NVARCHAR(100), Website1 NVARCHAR(1000), Website2 NVARCHAR(1000), Website3 NVARCHAR(1000), Website4 NVARCHAR(1000), MinorBettypeId INT, ParentHashKey VARCHAR(200), IsNeutral BIT, EtPk NVARCHAR(2000))
            ORDER BY ISNULL(MinorBettypeId, 0) DESC;
     EXEC sp_xml_removedocument 
          @idoc;

     -- Insert League
     INSERT INTO dbo.OWPLeague(OWPLeagueName)
            SELECT DISTINCT 
                   m.League
            FROM #tmpTable AS m
                 LEFT JOIN dbo.OWPLeague AS l WITH(NOLOCK) ON m.League = l.OWPLeagueName
            WHERE l.OWPLeagueId IS NULL;
     -- UPDATE LeagueId to temp table
     UPDATE m
       SET 
           m.LeagueId = l.OWPLeagueId
     FROM #tmpTable m
          INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON m.League = l.OWPLeagueName;

     -- Insert Home Team
     INSERT INTO dbo.OWPTeam(OWPTeamName)
            SELECT DISTINCT 
                   m.Home
            FROM #tmpTable AS m
                 LEFT JOIN dbo.OWPTeam AS t WITH(NOLOCK) ON m.Home = t.OWPTeamName
            WHERE t.OWPTeamId IS NULL;
     -- UPDATE HomeId to temp table
     UPDATE m
       SET 
           m.HomeId = t.OWPTeamId
     FROM #tmpTable m
          INNER JOIN dbo.OWPTeam t WITH(NOLOCK) ON m.Home = t.OWPTeamName;

     -- Insert Away Team
     INSERT INTO dbo.OWPTeam(OWPTeamName)
            SELECT DISTINCT 
                   m.Away
            FROM #tmpTable AS m
                 LEFT JOIN dbo.OWPTeam AS t WITH(NOLOCK) ON m.Away = t.OWPTeamName
            WHERE t.OWPTeamId IS NULL;
     -- UPDATE AwayId to temp table
     UPDATE m
       SET 
           m.AwayId = t.OWPTeamId
     FROM #tmpTable m
          INNER JOIN dbo.OWPTeam t WITH(NOLOCK) ON m.Away = t.OWPTeamName;

     -- Insert or UPDATE OWPMatch
     MERGE INTO dbo.OWPMatch WITH(ROWLOCK) AS om
     USING #tmpTable AS m
     ON m.LeagueId = om.OWPLeagueId
        AND m.HomeId = om.OWPHomeId
        AND m.AwayId = om.OWPAwayId
        AND om.EventDateTime >= @EventFromDateTime
        AND om.EventDateTime < @EventToDateTime
        AND (m.IsSaba = 0
             OR m.KickOffTime = om.KickOffTime)
         WHEN MATCHED
         THEN UPDATE SET 
                         om.MatchNo = m.MatchNo, 
                         om.EventDate = m.EventDate, 
                         om.KickOffTime = m.KickOffTime, 
                         om.OtherTime = m.OtherTime, 
                         om.EventDateTime = m.EventDate + CAST(m.KickOffTime AS DATETIME), 
                         om.InfoSiteMatchId = m.InfoSiteMatchId, 
                         om.MatchId = m.AdminSiteId, 
                         om.IsNeutral = m.IsNeutral
         WHEN NOT MATCHED BY TARGET
         THEN
           INSERT([MatchNo], 
                  [EventDate], 
                  [KickOffTime], 
                  [OWPLeagueId], 
                  [OWPHomeId], 
                  [OWPAwayId], 
                  [OtherTime], 
                  [EventDateTime], 
                  [InfoSiteMatchId], 
                  [MatchId], 
                  [IsNeutral])
           VALUES
     (m.[MatchNo], 
      m.[EventDate], 
      m.[KickOffTime], 
      m.[LeagueId], 
      m.[HomeId], 
      m.[AwayId], 
      m.[OtherTime], 
      m.EventDate + CAST(m.KickOffTime AS DATETIME), 
      m.[InfoSiteMatchId], 
      m.[AdminSiteId], 
      m.[IsNeutral]
     );

     -- UPDATE MatchId to temp table
     UPDATE m
       SET 
           m.OWPMatchId = om.OWPMatchId
     FROM #tmpTable m
          INNER JOIN dbo.OWPMatch om WITH(NOLOCK) ON m.LeagueId = om.OWPLeagueId
                                                     AND m.HomeId = om.OWPHomeId
                                                     AND m.AwayId = om.OWPAwayId
                                                     AND m.IsNeutral = om.IsNeutral
                                                     AND om.EventDateTime >= @EventFromDateTime
                                                     AND om.EventDateTime < @EventToDateTime
                                                     AND (m.IsSaba = 0
                                                          OR m.KickOffTime = om.KickOffTime);

     -- INSERT missing MatchInfo
     INSERT INTO dbo.MatchInfo(OWPMatchId)
            SELECT DISTINCT 
                   m.OWPMatchId
            FROM #tmpTable AS m
                 LEFT JOIN dbo.MatchInfo i WITH(NOLOCK) ON m.OWPMatchId = i.OWPMatchId
            WHERE i.OWPMatchId IS NULL;

     -- UPDATE Match Info
     UPDATE i
       SET 
           i.[Channel] = m.[Channel], 
           i.[IPTV] = m.[IPTV], 
           i.[WB] = m.[WB], 
           i.[Phone] = m.[Phone], 
           i.[Round] = m.[Round], 
           i.[Division] = m.[Division], 
           i.[Remark] = m.[Remark], 
           i.[Website1] = m.[Website1], 
           i.[Website2] = m.[Website2], 
           i.[Website3] = m.[Website3], 
           i.[Website4] = m.[Website4], 
           i.[MatchStatus] = m.[MatchStatus], 
           i.[NoOfHDPId] = r.[ResourceId], 
           i.[IsSelected] = 1, 
           i.[SelectedBy] = @UserId, 
           i.IsSelectedUpdatedDate = GETDATE(), 
           i.ETPK = m.ETPK
     FROM #tmpTable AS m
          INNER JOIN dbo.MatchInfo i WITH(NOLOCK) ON m.OWPMatchId = i.OWPMatchId
          LEFT JOIN dbo.RefResource r WITH(NOLOCK) ON r.RefName = 'NoOfHDP'
                                                      AND r.[Value] = m.NoHDP;

     -- DELETE MinorMatch
     DELETE mm
     FROM dbo.MinorMatch mm
          INNER JOIN #tmpTable t ON mm.MinorMatchId = t.OWPMatchId;
     DELETE mm
     FROM dbo.MinorMatch mm
          INNER JOIN #tmpTable t ON mm.ParentMatchId = t.OWPMatchId;

     -- INSERT MinorMatch
     INSERT INTO [dbo].[MinorMatch]
     ([MinorMatchId], 
      [ParentMatchId], 
      [MinorBettypeId], 
      [IsRepresented], 
      [GroupId]
     )
            SELECT DISTINCT 
                   t.OWPMatchId, 
                   m.OWPMatchId, 
                   t.MinorBettypeId, 
                   1, 
                   NULL
            FROM #tmpTable t
                 INNER JOIN #tmpTable m ON t.ParentHashKey = m.HashKey
            WHERE ISNULL(t.MinorBettypeId, 0) < 0;

     -- SELECT the result
     SELECT HashKey, 
            OWPMatchId
     FROM #tmpTable;
     DROP TABLE #tmpTable;