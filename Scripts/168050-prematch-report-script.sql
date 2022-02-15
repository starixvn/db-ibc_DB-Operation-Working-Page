
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20220208@Liam.Pham
Task : New table
DB: bodb_OWP	

Revisions:
	20220208@Liam.Pham: Initial - [Redmine: #168050]
*/

CREATE TABLE PreMatchReportLeague
(Id        INT IDENTITY(1, 1) PRIMARY KEY, 
 UserId    INT, 
 GroupId   INT, 
 Amount    INT, 
 BetType   INT, 
 EventDate DATE
);

CREATE TABLE PreMatchReportMatch
(Id        INT IDENTITY(1, 1) PRIMARY KEY, 
 UserId    INT, 
 GroupId   INT, 
 Amount    INT, 
 BetType   INT, 
 EventDate DATE
);

CREATE INDEX idx_eventdate 
ON PreMatchReportLeague(EventDate);

CREATE INDEX idx_eventdate 
ON PreMatchReportMatch(EventDate);