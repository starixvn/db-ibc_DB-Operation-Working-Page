/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20210922@carlos
Task : New table
DB: bodb_OWP	

Revisions:
	20210922@Tyler: Initial - [Redmine: #156929]
	
*/
CREATE TABLE TicketIssue (
	TicketId INT IDENTITY(1,1) PRIMARY KEY,
	TicketType INT NOT NULL,
	CreatedDate DATETIME NOT NULL
)

CREATE TABLE TicketIssueLeague(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	TicketId INT NOT NULL,
	OwpLeagueId INT NOT NULL
)

CREATE TABLE TicketIssueEvent(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	TicketId INT NOT NULL,
	OwpLeagueId INT NOT NULL,
	OwpHomeId INT NOT NULL,
	OwpAwayId INT NOT NULL
)

CREATE TABLE TicketIssueOther(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	TicketId INT NOT NULL,
	[Subject] NVARCHAR(2000) NOT NULL
)

CREATE TABLE TicketMessage (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	TicketId INT NOT NULL,
	[CreatedDate] DATETIME NOT NULL,
	[Message] NVARCHAR(2000) NOT NULL,
	UserId INT NOT NULL,
	IsSaved BIT
)

ALTER TABLE TicketMessage
ADD FileId INT

CREATE TABLE TicketRecipient(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	TicketId INT NOT NULL,
	RecipientId INT NOT NULL,
	RecipientType INT
)

