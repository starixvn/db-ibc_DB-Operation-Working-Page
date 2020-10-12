
/*
	Created: xxx
	Date: 20191017
	Task: schema [Redmine: #122604]
	DB: bodb_OWP
*/

USE bodb_OWP;
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_UserLog_ObjectId_UserLogId]
    ON [dbo].[UserLog](ObjectId ASC, UserLogId ASC)
    ON [OWP_Index];