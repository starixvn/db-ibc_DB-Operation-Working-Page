/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

/*
Created: 20210923@Carlos
Task : New table LinkLeagueAndTeam 
ref: https://nexdev.net/projects/operation-electronic-records/wiki/Link_League_and_Match
DB: bodb_OWP	

Revisions:
	20210923@Carlos: New table LinkLeagueAndTeam - [Redmine: #160543]
*/


CREATE TABLE LinkLeagueAndTeam(
	OWPTeamId INT NOT NULL PRIMARY KEY,
	OWPLeagueId INT,
	LastUpdate DATETIME
)

CREATE INDEX idx_OWPTeamId
ON LinkLeagueAndTeam (OWPTeamId)

