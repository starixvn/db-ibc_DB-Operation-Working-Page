
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20230209@Carlos.nguyen
Task : Add refresource
DB: bodb_OWP	

Revisions:
	20230209@Carlos.nguyen: Add refresource - [Redmine: #183243]
*/

DELETE RefResource
WHERE RefName = 'MultipleGames';

INSERT INTO RefResource
(RefName, 
 ResourceId, 
 [Value], 
 [Order]
)
VALUES
('UserLevel', 
 6, 
 '1st', 
 1
),
('UserLevel', 
 7, 
 '2nd', 
 2
),
('UserLevel', 
 8, 
 '[OP]1st', 
 3
),
('UserLevel', 
 9, 
 '[OP]2nd', 
 4
),
('UserLevel', 
 10, 
 'Only SB', 
 5
),
('UserLevel', 
 11, 
 'PIC', 
 1
),
('UserLevel', 
 12, 
 'D', 
 5
),
('UserLevel', 
 13, 
 'E', 
 6
),
('BetTypePreferences', 
 7, 
 '2[HDP]', 
 7
),
('BetTypePreferences', 
 8, 
 '2[OU]', 
 8
),
('BetTypePreferences', 
 9, 
 'BK CR', 
 9
),
('BetTypePreferences', 
 10, 
 'SB', 
 10
),
('BetTypePreferences', 
 11, 
 'FS', 
 11
),
('BetTypePreferences', 
 12, 
 'SB*2', 
 12
),
('BetTypePreferences', 
 13, 
 'SB*4', 
 13
),
('BetTypePreferences', 
 14, 
 '5min', 
 14
),
('BetTypePreferences', 
 15, 
 '6min', 
 15
),
('BetTypePreferences', 
 16, 
 'RB*2', 
 16
),
('BetTypePreferences', 
 17, 
 'RB*4', 
 17
),
('BetTypePreferences', 
 18, 
 'RB*6', 
 18
),
('BetTypePreferences', 
 19, 
 'FC', 
 19
),
('BetTypePreferences', 
 20, 
 'SM', 
 20
),
('BetTypePreferences', 
 21, 
 'MR', 
 21
),
('BetTypePreferences', 
 22, 
 'IPTV', 
 22
),
('BetTypePreferences', 
 23, 
 'CR', 
 23
),
('BetTypePreferences', 
 24, 
 'FA', 
 24
),
('BetTypePreferences', 
 25, 
 'TM, FM', 
 25
),
('BetTypePreferences', 
 26, 
 '2in1', 
 26
),
('BetTypePreferences', 
 27, 
 'TB', 
 27
),
('MultipleGames', 1, '1G', 1),
('MultipleGames', 2, '2G', 2),
('MultipleGames', 3, '3G', 3),
('MultipleGames', 4, '1G-no LA', 4),
('MultipleGames', 5, '2G-1LA', 5),
('MultipleGames', 6, '3G-2LAs', 6);

--EXECUTE

CREATE TABLE SectionLevelDefault
([LevelId] INT NOT NULL, 
 [Order]   INT
);
INSERT INTO SectionLevelDefault
([LevelId], 
 [Order]
)
VALUES
(1, 
 1
),
(2, 
 2
),
(3, 
 3
),
(4, 
 4
),
(5, 
 5
);
CREATE TABLE SectionLevel
(SectionId INT NOT NULL, 
 [LevelId] INT NOT NULL, 
 [Order]   INT
);
INSERT INTO SectionLevel
(SectionId, 
 [LevelId], 
 [Order]
)
VALUES
(2, 
 11, 
 1
),
(2, 
 2, 
 2
),
(2, 
 4, 
 3
),
(2, 
 5, 
 4
),
(2, 
 12, 
 5
),
(2, 
 13, 
 6
),
(3, 
 6, 
 1
),
(3, 
 7, 
 2
),
(3, 
 8, 
 3
),
(3, 
 9, 
 4
),
(3, 
 10, 
 5
),
(30, 
 11, 
 1
),
(30, 
 2, 
 2
),
(30, 
 4, 
 3
),
(30, 
 5, 
 4
),
(30, 
 12, 
 5
),
(30, 
 13, 
 6
);

--EXECUTE

CREATE TABLE SectionBetTypePreferencesDefault
([BettypeId] INT NOT NULL, 
 [Order]     INT
);
INSERT INTO SectionBetTypePreferencesDefault
([BettypeId], 
 [Order]
)
VALUES
(1, 
 1
),
(2, 
 2
),
(3, 
 3
),
(4, 
 4
),
(5, 
 5
),
(6, 
 6
);
IF OBJECT_ID('dbo.SectionBetTypePreferences', 'U') IS NOT NULL
    DROP TABLE dbo.[SectionBetTypePreferences]; 
GO
CREATE TABLE SectionBetTypePreferences
(SectionId   INT NOT NULL, 
 [BettypeId] INT NOT NULL, 
 [Order]     INT
);

--EXECUTE
INSERT INTO SectionBetTypePreferences
(SectionId, 
 [BettypeId], 
 [Order]
)
VALUES
(2, 
 12, 
 1
),
(2, 
 13, 
 2
),
(2, 
 14, 
 3
),
(2, 
 15, 
 4
),
(2, 
 16, 
 5
),
(2, 
 17, 
 6
),
(2, 
 18, 
 7
),
(2, 
 19, 
 8
),
(2, 
 20, 
 9
),
(2, 
 21, 
 10
),
(2, 
 11, 
 11
),
(2, 
 22, 
 12
),
(2, 
 23, 
 13
),
(2, 
 24, 
 14
),
(2, 
 25, 
 15
),
(2, 
 26, 
 16
),
(2, 
 27, 
 17
),
(3, 
 1, 
 1
),
(3, 
 7, 
 2
),
(3, 
 8, 
 3
),
(3, 
 9, 
 4
),
(3, 
 2, 
 5
),
(3, 
 10, 
 6
),
(3, 
 11, 
 7
),
(30, 
 12, 
 1
),
(30, 
 13, 
 2
),
(30, 
 14, 
 3
),
(30, 
 15, 
 4
),
(30, 
 16, 
 5
),
(30, 
 17, 
 6
),
(30, 
 18, 
 7
),
(30, 
 19, 
 8
),
(30, 
 20, 
 9
),
(30, 
 21, 
 10
),
(30, 
 11, 
 11
),
(30, 
 22, 
 12
),
(30, 
 23, 
 13
),
(30, 
 24, 
 14
),
(30, 
 25, 
 15
),
(30, 
 26, 
 16
),
(30, 
 27, 
 17
)


DROP PROCEDURE [dbo].[OWP_ProductAssignment_GetUserBy_User_Role_Section]

CREATE TABLE UserBetTypePreferences
([Id]        [INT] IDENTITY(1, 1) NOT NULL, 
 UserId      INT NOT NULL, 
 [BettypeId] INT NOT NULL
);

ALTER TABLE [User]
DROP COLUMN BetTypePreferencesId;


-- Initial config data for user --
CREATE TABLE #temp
(username    NVARCHAR(200), 
 level       NVARCHAR(200), 
 mainBettype NVARCHAR(200), 
 multipleMaxGame     NVARCHAR(200)
);
INSERT INTO #temp
(username, 
 level, 
 mainBettype, 
 multipleMaxGame
)
VALUES
('CLGBoon', '1st', '2[HDP]', ''),
('CLGShootbird', '1st', '2[OU]', ''),
('CLGChai', '1st', '2[HDP]', ''),
('CLGChian', '1st', '2[HDP]', ''),
('CLGGee', '1st', '2[HDP]', ''),
('CLGRaymond', '1st', '2[HDP]', ''),
('CLGTeoh', '1st', '2', ''),
('CLGFai', '1st', '2[HDP], FS', ''),
('CLGCandy', '1st', '2[HDP]', ''),
('CLGHan', '1st', '2[OU]', ''),
('CLGHendra', '1st', '2[HDP]', ''),
('CLGHoo', '1st', '2[OU]', ''),
('CLGKelven', '1st', '2[OU]', ''),
('CLGKern', '1st', '2[OU]', ''),
('CLGKuik', '1st', '2', ''),
('CLGWen', '1st', '2[HDP]', ''),
('CLGBay', '1st', '2[OP]', ''),
('CLGYao', '1st', '2[OP]', ''),
('CLGSeang', '1st', '2[OU]', ''),
('CLGPing', '1st', '2', ''),
('SLGYen', '1st', '2', ''),
('SLGAlbert', '1st', '2', ''),
('SLGRandy', '1st', '2', ''),
('SLGLuke', '1st', '2[OP]', ''),
('SLGJiaming', '1st', '2[OU]', ''),
('CLGAIK', '1st', '2[OU], FS', ''),
('CLGGreen', '[OP]1st', '2[OP]', ''),
('CLGLukeyap', '[OP]1st', '2[OP]', ''),
('CLGMan88', '[OP]1st', '2[OP]', ''),
('CLGTony', '[OP]1st', '2[OP]', ''),
('CLGEdy', '[OP]2nd', '2[OP]', ''),
('CLGTonykho', '[OP]2nd', '2[OP]', ''),
('CLGIvan', '[OP]2nd', '2[OP]', ''),
('CLGPiew', '[OP]2nd', '2[OP]', ''),
('CLGTommy', '1st', '2[HDP]', ''),
('CLGJacky', '1st', '2[OU]', ''),
('CLGJon', '1st', '2[OU], FS', ''),
('CLGKokchen', '1st', '2[OU]', ''),
('CLGShuan', '1st', '2[OU]', ''),
('CLGJoseph', '1st', '2', ''),
('CLGParker', '1st', '2[HDP]', ''),
('CLGKit', '1st', '2', ''),
('CLGAlikin', '1st', '2', ''),
('CLGBoonlay', '1st', '2', ''),
('CLGSusan', '1st', '2', ''),
('CLGAaron', '1st', '2[OU]', ''),
('CLGKilos', '1st', '2[HDP]', ''),
('CLGSern', '2nd', '2', ''),
('CLGIndo', '2nd', '2', ''),
('CLGChang', '2nd', '2[HDP]', ''),
('CLGCkeen', '2nd', '2', ''),
('CLGKien', '2nd', '2', ''),
('CLGHuat', '2nd', '2, BK CR, FS', ''),
('CLGGillian', '2nd', '2[OU], BK CR, FS', ''),
('CLGSan', '', '2[HDP]', ''),
('CLGSandy', '', '2[OU]', ''),
('CLGNhi', '', '2[OU]', ''),
('CLGLouis', '', '2[HDP]', ''),
('CLGManzai', '', '2, BK CR', ''),
('CLGMichelle', '', 'BK CR, 2[OU]', ''),
('CLGSaelee', '', 'BK CR, 2[HDP]', ''),
('CLGChee', '', '2', ''),
('CLGKentham', '', '2', ''),
('CLGWai', '', '2', ''),
('CLGHonsang', '', '2[HDP]', ''),
('CLGNikkol', '', '2[OU]', ''),
('CLGRobin', '', '2', ''),
('CLGRuby', '', '2[OU]', ''),
('CLGSiang', '', 'BK CR, 2[OU]', ''),
('CLGTommylim', '', 'BK CR, 2', ''),
('CLGTeckkeong', '', 'BK CR, 2', ''),
('CLGGary', '', '2[HDP]', ''),
('CLGLee', '', '2', ''),
('CLGYew', '', '2', ''),
('CLGTeck', '', '2[OU]', ''),
('CLGCam', '', '2', '3G-2LAs'),
('CLGXavi', '', '2', '3G-2LAs'),
('CLGDexter', '', '2', '2G-1LA'),
('CLGSOON', 'Only SB', 'SB', ''),
('CLGKarunia', '', '2, SB', '3G'),
('CLGTotti', '', '2, SB', '3G-2LAs'),
('SLGWubai', '1st', '2[OU]', ''),
('SLGBoy', '1st', '2', ''),
('SLGB2[OU]', '1st', '2, FS', ''),
('SLGMing', '2nd', '2', ''),
('SLGWanjie', '', '2', ''),
('SLGGoh', '', '2', ''),
('SLGJeffrey', '', '2', ''),
('SLGKenHong', '', '2', ''),
('SLGPlang', '', '2[OU]', ''),
('SLGTheeng', '', '2', ''),
('SLGTom', '2nd', '2[HDP]', ''),
('SLGJenny', '2nd', '2[OU]', ''),
('SLGTylen', '2nd', '2', ''),
('SLGNeo', '2nd', '2, FS', ''),
('SLGOscar', '2nd', '2', ''),
('SLGChris', '2nd', '2[HDP], 2[OU], FS', ''),
('SLGLina', '2nd', '2[OU]', ''),
('SLGNarsi', '2nd', '2, FS', ''),
('SLGHanwei', '2nd', '2', ''),
('SLGJanet', '', '2', ''),
('SLGKris', '', '2', ''),
('SLGCory', '', '2', ''),
('SLGLMax', '', '2', ''),
('SLGBaron', '', '2', ''),
('SLGDickson', '', '2', ''),
('SLGEven', '', '2', '3G-2LAs'),
('SLGKarson', '[OP]2nd', '2[OP]', ''),
('SLAFattchai', 'PIC', '', ''),
('SLAMango', 'PIC', '', ''),
('SLAEdison', 'PIC', '', ''),
('SLAPuiPui', 'PIC', '', ''),
('SLARaymond', 'PIC', '', ''),
('SLATank', 'PIC', '', ''),
('SLABilly', 'PIC', '', ''),
('SLABosco', 'PIC', '', ''),
('SLASunny', 'PIC', '', ''),
('SLAKeity', 'PIC', '', ''),
('SLARain', 'PIC', '', ''),
('SLASammy', 'PIC', '', ''),
('SLAWayne', 'PIC', '', ''),
('SLAHaden', 'A', '2in1, FS', ''),
('SLAAlly', 'A', '2in1, FS', ''),
('SLASpike', 'A', '2in1, FS', ''),
('SLARobert', 'A', '2in1, FS', ''),
('SLAHilary', 'A', '2in1, FS', ''),
('SLADaisy', 'A', '2in1, FS', ''),
('SLAEnix', 'A', '2in1, FS', ''),
('SLAAngely', 'A', '2in1, FS', ''),
('SLAKenglee', 'A', '2in1, FS', ''),
('SLASilva', 'A', '2in1, FS', ''),
('SLAHuson', 'A', '2in1, FS', ''),
('SLAHanson', 'B', '2in1, FS', ''),
('SLACataleya', 'B', '2in1, FS', ''),
('SLAJenny', 'B', '2in1, FS', ''),
('SLAVincent', 'B', '2in1, FS', ''),
('SLAAndrea', 'B', '2in1, FS', ''),
('SLAHardy', 'B', '2in1, FS', ''),
('SLASumi', 'B', '2in1, FS', ''),
('SLAAilee', 'B', '2in1, FS', ''),
('SLAYang', 'B', '2in1, FS', ''),
('SLADennix', 'B', '2in1, FS', ''),
('SLASimba', 'B', '2in1, FS', ''),
('SLASharon', 'B', '2in1, FS', ''),
('SLAJay', 'B', '2in1, FS', ''),
('SLAWanbi', 'B', '2in1, FS', ''),
('SLAOzil', 'B', '2in1, FS', ''),
('SLAHazard', 'B', '2in1, FS, TB', ''),
('SLADraven(VN)', 'B', '2in1, FS, TB', ''),
('SLAHarris', 'B', '2in1, FS', ''),
('SLALucia(VN)', 'B', '2in1, FS', ''),
('SLAKyo(VN)', 'B', '2in1, FS', ''),
('SLATony.Nguyen(VN)', 'B', 'SB*4', ''),
('SLAEren', 'B', '2in1, FS', ''),
('SLAPony', 'B', '2in1, FS, FA', ''),
('SLAQuest(VN)', 'B', '2in1, FS, FA', ''),
('SLAHaomaru', 'C', '2in1', ''),
('SLALynn', 'D', 'IPTV, FA, MR', ''),
('SLATommy.Tran', 'D', 'IPTV, FA, MR', ''),
('SLARose(VN)', 'D', 'IPTV, FA, MR', ''),
('SLAGallen', 'D', 'IPTV, MR', ''),
('SLAAlan', 'D', 'IPTV, MR', ''),
('SLALahm', 'E', 'RB*6', ''),
('SLAMicht', 'E', 'RB*6', ''),
('SLATulins', 'E', 'SB*4', ''),
('SLAHirene', 'E', 'SB*4', ''),
('SLALaatee1', 'E', 'SB*4', ''),
('SLANaultad', 'E', 'SB*4', ''),
('SLAShaoWei', 'E', 'SB*4', ''),
('SLAJes', 'E', 'SB*4', ''),
('SLAShirley', 'E', 'SB*4', ''),
('SLABella', 'E', 'SB*4', ''),
('SLAPhoenix(N)', 'E', 'SB*4', ''),
('SLAShen(N)', 'E', 'SB*4', ''),
('SLAKayjun(N)', 'E', 'SB*2', ''),
('SLADan(N)', 'E', 'SB*3', ''),
('CLAHonliang', 'PIC', '', ''),
('CLAHock', 'PIC', '', ''),
('CLAMax', 'PIC', '', ''),
('CLAJoey', 'A', '2in1', ''),
('CLAMay', 'A', '2in1', ''),
('CLACharlie', 'B', '2in1', ''),
('CLAAJ', 'B', '2in1', ''),
('CLARean', 'B', '2in1', ''),
('CLAJami', 'B', '2in1', ''),
('CLAAra', 'B', '2in1', ''),
('CLAAyessa', 'B', '2in1', ''),
('CLAAileen', 'B', '2in1', ''),
('CLADenmark', 'B', '2in1', ''),
('CLAJC', 'B', '2in1', ''),
('CLAJoy', 'B', '2in1', ''),
('CLAApril', 'B', '2in1', ''),
('CLAKarla', 'B', '2in1, FA', ''),
('CLAKeng', 'E', 'RB*6, FC', ''),
('CLAMC', 'E', 'FC, RB*4', ''),
('CLATINE', 'E', 'FC, RB*4', ''),
('CLAJen', 'E', 'RB*2', ''),
('CLAJoyce', 'E', 'SB*4', '')

UPDATE u
  SET 
      u.Level = rrl.ResourceId, 
      u.MultipleGamesId = rrmg.ResourceId
FROM [User] u
     INNER JOIN #temp t ON t.username = u.Username
     LEFT JOIN RefResource rrl WITH(NOLOCK) ON t.level = rrl.Value
                                               AND rrl.RefName = 'UserLevel'
     LEFT JOIN RefResource rrmg WITH(NOLOCK) ON t.multipleMaxGame = rrmg.Value
                                                AND rrmg.RefName = 'MultipleGames'
												where rrmg.Value is NUll or rrl.Value is null

-- insert main bettype
INSERT INTO UserBetTypePreferences
(UserId, 
 BettypeId
)
       SELECT u.UserId, 
              rrbt.ResourceId
       FROM
       (
           SELECT t.username, 
                  LTRIM(RTRIM(f.value)) AS mainBetType
           FROM #temp AS t
                CROSS APPLY STRING_SPLIT(t.mainBettype, ',') AS f
       ) AS mbttemp
       INNER JOIN [User] u ON mbttemp.username = u.Username
       LEFT JOIN RefResource rrbt WITH(NOLOCK) ON mbttemp.mainBettype = rrbt.Value
                                                  AND rrbt.RefName = 'BetTypePreferences'
       WHERE rrbt.ResourceId IS NOT NULL;

-- drop temp table
DROP TABLE #temp;