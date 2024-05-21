
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250521@Mira
Task : Account Setting page
DB: bodb_OWP

Revisions:
	20250521@Mira: create new table for Account Setting Page - [Redmine: #201603]
*/

-- new table QuickMessage
CREATE TABLE dbo.QuickMessage
(Id          INT IDENTITY(1, 1) PRIMARY KEY, 
 Shortcut    NVARCHAR(100) NOT NULL, 
 [Message]   NVARCHAR(1000) NOT NULL, 
 CreatedDate DATETIME NOT NULL, 
 CreatorId   INT NOT NULL
);

-- new table UserProfile
CREATE TABLE dbo.UserProfile
(UserId INT NOT NULL, 
 FileId INT NULL
);