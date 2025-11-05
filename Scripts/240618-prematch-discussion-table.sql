/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

/*
Created: 20251017@Hank
Task : Add columns to MaxbetSetting table for spread
DB: bodb_OWP	

Revisions:
	 20251017@Hank: Add columns to MaxbetSetting table for spread - [Redmine: #241435]
*/
USE bodb_OWP
GO

CREATE TABLE PreMatchDiscussion (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
	CreatedBy INT NOT NULL,
	UpdatedDate DATETIME NULL DEFAULT GETDATE(),
	UpdatedBy INT NULL
);

CREATE TABLE PreMatchDiscussionInfo (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	DiscussionId INT NOT NULL,
	InfoSiteMatchId INT NOT NULL,
	BetType INT NOT NULL,
	RCDiscussionId INT NOT NULL,
	BetOn NVARCHAR(100) NOT NULL,
	GhostName NVARCHAR(100) NOT NULL,
	GhostDetail NVARCHAR(2000) NOT NULL,
	HdpOu MONEY NULL,
	Odds MONEY NULL,
	Note NVARCHAR(MAX) NULL,
	Remark NVARCHAR(MAX) NULL
);

CREATE INDEX idx_DiscussionId ON PreMatchDiscussionInfo(DiscussionId);
CREATE INDEX idx_InfoSiteMatchId ON PreMatchDiscussionInfo(InfoSiteMatchId);
