
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20201201@Tyler
Task : event tickets enhancement phase 2
DB: bodb_OWP	

Revisions:
	20201201@Tyler: Create new table for File Uploading - [Redmine: #145591]
*/

CREATE TABLE [dbo].[FileUpload]
([FileId]      [INT] IDENTITY(1, 1) NOT NULL, 
 [Title]       [NVARCHAR](100) NOT NULL, 
 [CreatedDate] [DATETIME] NOT NULL, 
 [FileContent] [VARBINARY](MAX) NOT NULL, 
 CONSTRAINT [PK_FileUpload] PRIMARY KEY CLUSTERED([FileId] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];

CREATE NONCLUSTERED INDEX IX_CreatedDate ON [dbo].[FileUpload]([CreatedDate] ASC);

CREATE NONCLUSTERED INDEX IX_CreatedDate ON [dbo].[PreMatchIssueMessage]([CreatedDate] ASC);

ALTER TABLE [dbo].[PreMatchIssueMessage]
ADD FileId INT;