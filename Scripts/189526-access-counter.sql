
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20230717@Los
Task : Create table AccessCounter
DB: bodb_OWP	

Revisions:
	20230717@Los: Create table AccessCounter [Redmine: #189526]
*/

CREATE TABLE [dbo].[AccessCounter]
([Id]    [INT] IDENTITY(1, 1) NOT NULL PRIMARY KEY, 
[Date]         DATETIME NOT NULL, 
 [UserId]    [INT] NOT NULL, 
 [Function]     NVARCHAR(500), 
 [Count] [INT]
)
ON [OWP_Data];
GO



