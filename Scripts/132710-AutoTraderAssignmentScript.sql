
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20210510@Mira
Task : Auto Trader Assignment
DB: bodb_OWP	

Revisions:
	20210510@Mira: Initial - [Redmine: #132710]
*/

-- AutoAssignmentResult
EXEC sp_RENAME 
     'dbo.AutoAssignmentResult.UserId', 
     'UserId_LA', 
     'COLUMN';
ALTER TABLE dbo.AutoAssignmentResult
ADD UserId_FTHDP INT NULL, 
    UserId_1HHDP INT NULL, 
    UserId_FTOU  INT NULL, 
    UserId_1HOU  INT NULL;
GO