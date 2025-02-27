/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250221@Frankie
Task : Event Picking New - Enhancement
DB: bodb_OWP

Revisions:
	20250221@Frankie: Add logs table  - [Redmine: #217894]
*/

CREATE TABLE OWPLogs(
Id INT IDENTITY(1,1) PRIMARY KEY,
CreatedDate DATE,
[Action] VARCHAR(255) NOT NULL,
[Payload] NVARCHAR(MAX)
)

CREATE NONCLUSTERED INDEX idx_action
ON OWPLogs ([Action]);

CREATE TABLE InfoSiteLogs(
Id INT IDENTITY(1,1) PRIMARY KEY,
CreatedDate DATE,
[Action] VARCHAR(255) NOT NULL,
[Payload] NVARCHAR(MAX)
)

CREATE NONCLUSTERED INDEX idx_action
ON InfositeLogs ([Action]);

CREATE TABLE AdminSiteLogs(
Id INT IDENTITY(1,1) PRIMARY KEY,
CreatedDate DATE,
[Action] VARCHAR(255) NOT NULL,
[Payload] NVARCHAR(MAX)
)

CREATE NONCLUSTERED INDEX idx_action
ON AdminSiteLogs ([Action]);