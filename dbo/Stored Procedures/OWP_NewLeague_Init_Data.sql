
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_NewLeague_Init_Data] @XML NVARCHAR(MAX)
AS

/*
Created: 20240424@Los
Task : Init new league
DB: bodb_OWP

Revisions:
	20240424@Los: Init league - [Redmine: #202639]
	20250723@Los: Init LeagueManagementSetting table - [Redmine: #233199]
    20250829@Hank: update new league short name - [Redmine: #233199]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @idoc INT;
        EXEC sp_xml_preparedocument 
             @idoc OUTPUT, 
             @XML;
        CREATE TABLE #tblLeague
        (LeagueGroup              NVARCHAR(200), 
         LeagueGroupId            INT, 
         League                   NVARCHAR(200) NOT NULL, 
         ShortLeague              NVARCHAR(200), 
         LeagueId                 INT, 
         FullConditionDescription NVARCHAR(MAX), 
         Spread_HDP_Value         MONEY NULL, 
         Spread_OU_Value          MONEY NULL, 
         Spread_Note              NVARCHAR(2000) NULL, 
         MaxbetWD_HDP_Value       MONEY NULL, 
         MaxbetWD_HDP_Note        NVARCHAR(2000) NULL, 
         WD_NoOfHDP_Value         NVARCHAR(2000) NULL, 
         WD_NoOfHDP_Note          NVARCHAR(2000) NULL, 
         MaxbetWK_HDP_Value       MONEY NULL, 
         MaxbetWK_HDP_Note        NVARCHAR(2000) NULL, 
         WK_NoOfHDP_Value         NVARCHAR(2000) NULL, 
         WK_NoOfHDP_Note          NVARCHAR(2000) NULL, 
         LSTNote                  NVARCHAR(2000) NULL, 
         Remark2                  NVARCHAR(2000) NULL, 
         Remark2WD                NVARCHAR(2000) NULL, 
         Remark2WK                NVARCHAR(2000) NULL, 
         Comment                  NVARCHAR(MAX),
        );
        INSERT INTO #tblLeague
        (LeagueGroup, 
         League, 
         ShortLeague, 
         FullConditionDescription, 
         Spread_HDP_Value, 
         Spread_OU_Value, 
         Spread_Note, 
         MaxbetWD_HDP_Value, 
         MaxbetWD_HDP_Note, 
         WD_NoOfHDP_Value, 
         WD_NoOfHDP_Note, 
         MaxbetWK_HDP_Value, 
         MaxbetWK_HDP_Note, 
         WK_NoOfHDP_Value, 
         WK_NoOfHDP_Note, 
         LSTNote, 
         Remark2, 
         Comment, 
         Remark2WD, 
         Remark2WK
        )
               SELECT [LeagueGroup], 
                      [League], 
                      [ShortLeague], 
                      [FullConditionDescription], 
                      [Spread_HDP_Value], 
                      [Spread_OU_Value], 
                      [Spread_Note], 
                      [MaxbetWD_HDP_Value], 
                      [MaxbetWD_HDP_Note], 
                      [WD_NoOfHDP_Value], 
                      [WD_NoOfHDP_Note], 
                      [MaxbetWK_HDP_Value], 
                      [MaxbetWK_HDP_Note], 
                      [WK_NoOfHDP_Value], 
                      [WK_NoOfHDP_Note], 
                      [LSTNote], 
                      [Remark2], 
                      [Comment], 
                      Remark2WD, 
                      Remark2WK
               FROM OPENXML(@idoc, '/Root/LeagueSettingInfo', 1) WITH([LeagueGroup] NVARCHAR(200), [League] NVARCHAR(200), [ShortLeague] NVARCHAR(200), [FullConditionDescription] NVARCHAR(MAX), [Spread_HDP_Value] MONEY, [Spread_OU_Value] MONEY, [Spread_Note] NVARCHAR(2000), [MaxbetWD_HDP_Value] MONEY, [MaxbetWD_HDP_Note] NVARCHAR(2000), [WD_NoOfHDP_Value] NVARCHAR(2000), [WD_NoOfHDP_Note] NVARCHAR(2000), [MaxbetWK_HDP_Value] MONEY, [MaxbetWK_HDP_Note] NVARCHAR(2000), [WK_NoOfHDP_Value] NVARCHAR(2000), [WK_NoOfHDP_Note] NVARCHAR(2000), [LstNote] NVARCHAR(2000), [Remark2] NVARCHAR(2000), [Comment] NVARCHAR(MAX), Remark2WD NVARCHAR(2000), Remark2WK NVARCHAR(2000));
        EXEC sp_xml_removedocument 
             @idoc;

        /*Init league name*/

        INSERT INTO dbo.OWPLeague(OWPLeagueName)
               SELECT DISTINCT 
                      im.League
               FROM #tblLeague AS im
               WHERE NOT EXISTS
               (
                   SELECT 1
                   FROM dbo.OWPLeague AS l WITH(NOLOCK)
                   WHERE im.League = l.OWPLeagueName
               );

        -- Update NoOfferLive, BlackList
        UPDATE owpl
          SET 
              owpl.NoOfferLive = CASE
                                     WHEN tbll.LSTNote LIKE '%\[No Offer Live\]%' ESCAPE '\'
                                     THEN 1
                                     ELSE 0
                                 END, 
              owpl.IsBlackList = CASE
                                     WHEN tbll.LSTNote LIKE '%Blacklist%'
                                     THEN 1
                                     ELSE 0
                                 END
        FROM OWPLeague AS owpl WITH(NOLOCK)
             INNER JOIN #tblLeague AS tbll WITH(NOLOCK) ON tbll.League = owpl.OWPLeagueName;

        -- Update ShortLeague
        UPDATE owpl
          SET 
              owpl.ShortLeague = tbll.ShortLeague
        FROM OWPLeague AS owpl WITH(NOLOCK)
             INNER JOIN #tblLeague AS tbll WITH(NOLOCK) ON tbll.League = owpl.OWPLeagueName;

        -- update LeagueId
        UPDATE tbll
          SET 
              tbll.LeagueId = owpl.OWPLeagueId
        FROM #tblLeague AS tbll
             INNER JOIN OWPLeague AS owpl WITH(NOLOCK) ON tbll.League = owpl.OWPLeagueName;

        -- Insert new league setting

        INSERT INTO LeagueManagementSetting
        ([OWPLeagueId], 
         [FullConditionDescription], 
         [Spread_HDP], 
         [Spread_OU], 
         [Spread_Note], 
         [MaxbetWD_HDP], 
         [MaxbetWD_HDP_Note], 
         [WD_NoOfHDP], 
         [WD_NoOfHDP_Note], 
         [MaxbetWK_HDP], 
         [MaxbetWK_HDP_Note], 
         [WK_NoOfHDP], 
         [WK_NoOfHDP_Note], 
         [LSTNote], 
         [Remark2], 
         [Comment], 
         Remark2WD, 
         Remark2WK
        )
               SELECT tbll.LeagueId, 
                      tbll.FullConditionDescription,
                      CASE
                          WHEN tbll.Spread_HDP_value = ''
                          THEN NULL
                          ELSE tbll.Spread_HDP_value
                      END,
                      CASE
                          WHEN tbll.[Spread_OU_value] = ''
                          THEN NULL
                          ELSE tbll.[Spread_OU_value]
                      END, 
                      tbll.[Spread_Note],
                      CASE
                          WHEN tbll.[MaxbetWD_HDP_value] = ''
                          THEN NULL
                          ELSE tbll.[MaxbetWD_HDP_value]
                      END, 
                      tbll.[MaxbetWD_HDP_Note], 
                      tbll.[WD_NoOfHDP_value], 
                      tbll.[WD_NoOfHDP_Note],
                      CASE
                          WHEN tbll.[MaxbetWK_HDP_value] = ''
                          THEN NULL
                          ELSE tbll.[MaxbetWK_HDP_value]
                      END, 
                      tbll.[MaxbetWK_HDP_Note], 
                      tbll.[WK_NoOfHDP_value], 
                      tbll.[WK_NoOfHDP_Note], 
                      tbll.[LSTNote], 
                      tbll.[Remark2], 
                      tbll.[Comment], 
                      tbll.Remark2WD, 
                      tbll.Remark2WK
               FROM #tblLeague AS tbll;
        DROP TABLE #tblLeague;
    END;