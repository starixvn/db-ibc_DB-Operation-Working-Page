
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20210914@Mira
Task : Support log action on delete/merge events
DB: bodb_OWP

Revisions:
	20210914@Mira: Create tables for Service Log - [Redmine: #161379]
*/

IF OBJECT_ID('dbo.ServiceActionLog', 'U') IS NOT NULL
    DROP TABLE dbo.[ServiceActionLog]; 
GO
CREATE TABLE [dbo].[ServiceActionLog]
([LogId]        [INT] IDENTITY(1, 1) NOT NULL, 
 [ActionBy]     [NCHAR](30) NOT NULL, 
 [LogDate]      [DATETIME] NOT NULL, 
 [DataOld]      [NVARCHAR](MAX) NULL, 
 [DataNew]      [NVARCHAR](MAX) NULL, 
 [UpdatedField] [NCHAR](100) NULL, 
 [TableName]    [NCHAR](100) NULL, 
 [OWPMatchId]   [INT] NULL, 
 [SPName]       [NVARCHAR](100) NULL
)
ON [OWP_Data];
GO