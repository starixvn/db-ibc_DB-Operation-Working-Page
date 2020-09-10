
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20200811@Mira
Task : Pre-Match assignment
DB: bodb_OWP	

Revisions:
	20200811@Mira: Pre-Match assignment - [Redmine: #138643]
*/

CREATE TABLE [dbo].[PreMatchAssignment]
([PreMatchAssignmentId] INT NOT NULL,
 [EventDateTime] DATETIME NOT NULL, 
 [LeagueName]    NVARCHAR(400) NOT NULL,
 [HDP]           NVARCHAR(200) NOT NULL, 
 [OU]            NVARCHAR(200) NOT NULL, 
 [HDPTOver]      NVARCHAR(200) NOT NULL, 
 [OUTOver]       NVARCHAR(200) NOT NULL, 
 [isDeleted]     BIT NOT NULL, 
 CONSTRAINT [PK_PreMatchAssignment] PRIMARY KEY CLUSTERED([PreMatchAssignmentId] ASC)
);