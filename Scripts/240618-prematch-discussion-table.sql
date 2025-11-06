/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

/*
Created: 20251105@Hank
Task : Create tables for pre-match discussion
DB: bodb_OWP	

Revisions:
	 20251105@Hank: Create tables for pre-match discussion - [Redmine: #240618]
*/
USE bodb_OWP
GO

CREATE TABLE PreMatchDiscussion (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	IsIncludeTrader BIT NULL,
	CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
	CreatedBy INT NOT NULL,
	UpdatedDate DATETIME NULL DEFAULT GETDATE(),
	UpdatedBy INT NULL
);

CREATE TABLE PreMatchDiscussionInfo (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	DiscussionId INT NOT NULL,
	AdminSiteMatchId INT NOT NULL,
	BetType INT NOT NULL,
	RCDiscussionGroupId NVARCHAR(255) NULL,
	BetOn NVARCHAR(100) NOT NULL,
	HomeId INT NULL,
	AwayId INT NULL,
	GhostName NVARCHAR(100) NULL,
	GhostDetail NVARCHAR(2000) NULL,
	HdpOu MONEY NULL,
	Odds NVARCHAR(255) NULL,
	Note NVARCHAR(MAX) NULL,
	Remark NVARCHAR(MAX) NULL
);

CREATE INDEX idx_DiscussionId ON PreMatchDiscussionInfo(DiscussionId);
CREATE INDEX idx_InfoSiteMatchId ON PreMatchDiscussionInfo(AdminSiteMatchId);
