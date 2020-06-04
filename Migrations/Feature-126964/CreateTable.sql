/*
	Created: Carlos.nguyen
	Date: 20200604
	Task: [Redmine: #126964]
	DB: bodb_OWP
*/
USE bodb_OWP

CREATE TABLE AutoAssignmentMatchHistory
(
	MatchId INT NOT NULL,
	KOTime DATETIME NOT NULL,
	OtherTime VARCHAR(100),
	Bettype INT NOT NULL,
	MaxBet MONEY,
	Venue NVARCHAR(100),
	RequireChinese BIT,
	PRIMARY KEY(MatchId, Bettype)
)

CREATE TABLE AutoAssignmentSuspenderHistory
(
	UserId INT NOT NULL,
	InTime DATETIME NOT NULL,
	OutTime DATETIME NOT NULL,
	SpeakChinese BIT,
	SpeakEnglish BIT,
	PRIMARY KEY(UserId,InTime)
)
GO