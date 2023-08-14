
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20230814@Liam.pham
Task : Add 1st+ level, new bettype
DB: bodb_OWP	

Revisions:
	20230814@Liam.pham:  Add 1st+ level, new bettype - [Redmine: #189690]
*/
-- add new level 
INSERT INTO RefResource
(RefName, 
 ResourceId, 
 [Value], 
 [Order]
)
VALUES
('UserLevel', 
 14, 
 '1st+', 
 0
);

INSERT INTO SectionLevel
(SectionId, 
 [LevelId], 
 [Order]
)
VALUES
(3, 
 14, 
 0
);

--- update user level 
UPDATE [USER]
  SET 
      [Level] = 14
WHERE [User].Username IN('CLGBoon', 'CLGShootbird', 'CLGChai', 'CLGChian', 'CLGGee', 'CLGHan', 'CLGHoo', 'CLGWen', 'CLGSeang', 'SLGJiaming', 'CLGTommy', 'CLGJon', 'CLGShuan', 'CLGParker', 'CLGAaron', 'CLGKilos');

INSERT INTO RefResource
(RefName, 
 ResourceId, 
 [Value], 
 [Order]
)
VALUES
('BetTypePreferences', 
 31, 
 '16mins', 
 31
),
('BetTypePreferences', 
 32, 
 'M88', 
 32
);

--- add new bettype 
INSERT INTO SectionBetTypePreferences
(SectionId, 
 BettypeId, 
 [Order]
)
VALUES
(2, 
 31, 
 404
),
(30, 
 31, 
 404
),
(2, 
 32, 
 408
),
(30, 
 32, 
 408
);

UPDATE RefResource
  SET 
      [Value] = '5mins'
WHERE RefName = 'BetTypePreferences'
      AND ResourceId in (14,29);

UPDATE RefResource
  SET 
      [Value] = '6mins'
WHERE RefName = 'BetTypePreferences'
      AND ResourceId in (15,30)
