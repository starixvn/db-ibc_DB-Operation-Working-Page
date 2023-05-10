
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20230209@Carlos.nguyen
Task : Add refresource
DB: bodb_OWP	

Revisions:
	20230510@Carlos.nguyen: Insert data - [Redmine: #186520]
*/

DELETE FROM SectionBetTypePreferences
--EXECUTE
INSERT INTO SectionBetTypePreferences
(SectionId, 
 [BettypeId], 
 [Order]
)
VALUES
(2, 
 12, 
 100
),
(2, 
 13, 
 200
),
(2, 
 14, 
 300
),
(2, 
 15, 
 400
),
(2, 
 16, 
 500
),
(2, 
 17, 
 600
),
(2, 
 18, 
 700
),
(2, 
 19, 
 800
),
(2, 
 20, 
 900
),
(2, 
 21, 
 1000
),
(2, 
 11, 
 1100
),
(2, 
 22, 
 1200
),
(2, 
 23, 
 1300
),
(2, 
 24, 
 1400
),
(2, 
 25, 
 1500
),
(2, 
 26, 
 1600
),
(2, 
 27, 
 1700
),
(3, 
 1, 
 100
),
(3, 
 7, 
 200
),
(3, 
 8, 
 300
),
(3, 
 9, 
 400
),
(3, 
 2, 
 500
),
(3, 
 10, 
 600
),
(3, 
 11, 
 700
),
(30, 
 12, 
 100
),
(30, 
 13, 
 200
),
(30, 
 14, 
 300
),
(30, 
 15, 
 400
),
(30, 
 16, 
 500
),
(30, 
 17, 
 600
),
(30, 
 18, 
 700
),
(30, 
 19, 
 800
),
(30, 
 20, 
 900
),
(30, 
 21, 
 1000
),
(30, 
 11, 
 1100
),
(30, 
 22, 
 1200
),
(30, 
 23, 
 1300
),
(30, 
 24, 
 1400
),
(30, 
 25, 
 1500
),
(30, 
 26, 
 1600
),
(30, 
 27, 
 1700
)

INSERT INTO RefResource(RefName,ResourceId,[Value],[Order])
VALUES('BetTypePreferences',28,'RB*1',28)

INSERT INTO SectionBetTypePreferences(SectionId,BettypeId, [Order])
VALUES(2,28,410),
(30,28,410)


INSERT INTO RefResource(RefName,ResourceId,[Value],[Order])
VALUES('BetTypePreferences',29,'5min',29)

INSERT INTO SectionBetTypePreferences(SectionId,BettypeId, [Order])
VALUES(3,29,610)

INSERT INTO RefResource(RefName,ResourceId,[Value],[Order])
VALUES('BetTypePreferences',30,'6min',30)

INSERT INTO SectionBetTypePreferences(SectionId,BettypeId, [Order])
VALUES(3,30,620)