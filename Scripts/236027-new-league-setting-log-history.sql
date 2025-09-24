/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250924@carlos
Task : New table
DB: bodb_OWP	

Revisions:
	20250924@carlos: Initial - [Redmine: #236027]
	
*/
CREATE TABLE LeagueSettingLog(
[Id] [INT] IDENTITY(1, 1) NOT NULL,
CreatedDate DATETIME NOT NULL,
ModifiedBy NVARCHAR(255),
SettingId INT NOT NULL,
[Action] VARCHAR(200),
Content NVARCHAR(MAX),
)

CREATE NONCLUSTERED INDEX IX_LeagueSettingLog_SettingId
ON LeagueSettingLog (SettingId)

