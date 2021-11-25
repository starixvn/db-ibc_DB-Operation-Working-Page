/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20211119@carlos
Task : New table
DB: bodb_OWP	

Revisions:
	20211119@CarlosNguyen: Enhance-auto-assignment - [Redmine: #163362]
	
*/
ALTER TABLE InfoSiteMatch
ADD OtherProvider NVARCHAR(2000),
Provider NVARCHAR(2000),
Remark NVARCHAR(2000)

IF OBJECT_ID('dbo.InfoSiteSoloMatch', 'U') IS NOT NULL
    DROP TABLE dbo.[InfoSiteSoloMatch]; 
GO
CREATE TABLE [dbo].[InfoSiteSoloMatch]
([Id] [INT] IDENTITY(1, 1) NOT NULL, 
 [InfoSiteId]          [INT] NOT NULL, 
 [EventDateTime]      [DateTime] NOT NULL, 
 CONSTRAINT [PK_InfoSiteSoloMatch] PRIMARY KEY CLUSTERED([id] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];
GO

