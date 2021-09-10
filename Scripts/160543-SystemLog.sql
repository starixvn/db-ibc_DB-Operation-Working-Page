/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

/*
Created: 20210907@Carlos
Task : New table LinkLeagueAndTeam 
ref: https://nexdev.net/projects/operation-electronic-records/wiki/Link_League_and_Match
DB: bodb_OWP	

Revisions:
	20210907@Carlos: New table SystemLog - [Redmine: #160543]
*/


CREATE TABLE SystemLog(
	Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[Action] VARCHAR(255),
	SpName VARCHAR(255),
	LoggedDate DATETIME,
	Data NVARCHAR(MAX)
)

CREATE INDEX idx_SpName
ON SystemLog (SpName)

