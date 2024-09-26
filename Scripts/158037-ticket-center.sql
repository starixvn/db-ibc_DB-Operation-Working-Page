/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20210922@carlos
Task : New table
DB: bodb_OWP	

Revisions:
	20211011@carlos: Initial - [Redmine: #158037]
	20211015@Liam: Adding InfoSiteMatchId to TicketIssueEvent - [Redmine: #158037]
	
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
	[InfoSiteMatchId] INT NULL,
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
	IsSaved BIT,
	FileId INT
)

CREATE TABLE TicketCreator(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	TicketId INT NOT NULL,
	CreatorId INT NOT NULL,
	CreatedDate DATETIME NOT NULL
)

CREATE TABLE TicketRecipient(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	TicketId INT NOT NULL,
	RecipientId INT NOT NULL,
	RecipientType INT
)

CREATE TABLE TicketMessageReader(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	TicketId INT NOT NULL,
	RecipientId INT NOT NULL,
	IsRead BIT
)

