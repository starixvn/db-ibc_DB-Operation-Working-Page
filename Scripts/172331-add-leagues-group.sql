/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20220505@Luca.Duong
Task : Adding league groups
DB: bodb_OWP	

Revisions:
	20220505@Luca.Duong: insert new league groups - [Redmine: #172331]
*/

INSERT INTO RefResource(RefName,ResourceId,Value,[Order]) VALUES('LeagueCategory',12,'MJ.T1',0)
INSERT INTO RefResource(RefName,ResourceId,Value,[Order]) VALUES('LeagueCategory',13,'MJ.T2',0)
INSERT INTO RefResource(RefName,ResourceId,Value,[Order]) VALUES('LeagueCategory',14,'CL.MJ.Q',0)
INSERT INTO RefResource(RefName,ResourceId,Value,[Order]) VALUES('LeagueCategory',15,'CL.MN.Q',0)
INSERT INTO RefResource(RefName,ResourceId,Value,[Order]) VALUES('LeagueCategory',16,'INT.MJ',0)
INSERT INTO RefResource(RefName,ResourceId,Value,[Order]) VALUES('LeagueCategory',17,'INT.MN',0)
INSERT INTO RefResource(RefName,ResourceId,Value,[Order]) VALUES('LeagueCategory',18,'World Cup',0)
INSERT INTO RefResource(RefName,ResourceId,Value,[Order]) VALUES('LeagueCategory',19,'EURO',0)