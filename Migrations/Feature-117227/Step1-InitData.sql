/*
	Created: Leo.Vo
	Date: 20190724
	Task: [Redmine: #117227]
	DB: bodb_OWP
*/
USE bodb_OWP

INSERT INTO dbo.MajorBettype (BettypeId, Name, ShortName)
VALUES (-1001, 'XMins', 'XMins')
	,(-1003, 'Fast Market', 'FM')
	,(-1004, 'All In One', 'AIO')
	
DELETE dbo.[MinorBettype]
WHERE MinorBettypeId = - 40

DELETE dbo.MinorMatchDetemination
WHERE MinorBettypeId IN (- 41, - 42, - 43, - 44)

UPDATE dbo.MinorMatchTemplateSetting
SET League = REPLACE(rtrim(ltrim(League)), CHAR(13) + CHAR(10), '')
	,Home = REPLACE(rtrim(ltrim(Home)), CHAR(13) + CHAR(10), '')
	,Away = REPLACE(rtrim(ltrim(Away)), CHAR(13) + CHAR(10), '')