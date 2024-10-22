
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20220916@Mira
Task : LA Report
DB: bodb_OWP	

Revisions:
	20220916@Mira: Create tables for LA report enhancement - [Redmine: #177768]
*/

-- LA Report
IF OBJECT_ID('dbo.LAReport', 'U') IS NOT NULL
    DROP TABLE dbo.[LAReport]; 
GO
GO
CREATE TABLE [dbo].[LAReport]
([ReportDate]               DATE NOT NULL, 
 [UserId]                   INT NOT NULL, 
 [TotalMatches]             INT NULL, 
 [Link2]                    INT NULL, 
 [Link3]                    INT NULL, 
 [Link4]                    INT NULL, 
 [Link5]                    INT NULL, 
 [Link6]                    INT NULL, 
 [Link7]                    INT NULL, 
 [Link8Plus]                INT NULL, 
 [OnlyProvider]             INT NULL, 
 [OnlyTV]                   INT NULL, 
 [OnlyReporter]             INT NULL, 
 [MixedProviderTVReporter]  INT NULL, 
 [CornerPlus]               INT NULL, 
 [TBookingPlus]             INT NULL, 
 [Fantasy]                  INT NULL, 
 [GoalKick]                 INT NULL, 
 [OtherProducts]            INT NULL, 
 [FTCorner]                 INT NULL, 
 [FTCorner5ML]              INT NULL, 
 [FiveMajorLeague]          INT NULL, 
 [ESoccer5Mins]             INT NULL, 
 [ESoccer6Mins]             INT NULL, 
 [ESoccer15Mins]            INT NULL, 
 [ESoccer16Mins]            INT NULL, 
 [ESoccer20Mins]            INT NULL, 
 [Others]                   INT NULL, 
 [OthersProductOWPMatchIds] VARCHAR(MAX), 
 [CreatedDate]              DATETIMEOFFSET(7) NULL, 
 CONSTRAINT [PK_LAReport] PRIMARY KEY CLUSTERED([ReportDate] ASC, [UserId] ASC)
)
ON [OWP_Data];
GO