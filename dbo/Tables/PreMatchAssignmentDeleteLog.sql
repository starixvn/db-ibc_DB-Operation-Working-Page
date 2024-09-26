
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20200811@Mira
Task : Pre-Match assignment
DB: bodb_OWP	

Revisions:
	20200811@Mira: Pre-Match assignment - [Redmine: #138643]
*/

CREATE TABLE [dbo].[PreMatchAssignmentDeleteLog]
(DeletedAssignmentId INT NOT NULL,
 [PreMatchAssignmentId] INT NOT NULL,
 [DeltedBy] NVARCHAR(200) NOT NULL, 
 [DeletedTime]    DATETIME NOT NULL
 CONSTRAINT [PK_PreMatchAssignmentDeleteLog] PRIMARY KEY CLUSTERED([DeletedAssignmentId] ASC)
);