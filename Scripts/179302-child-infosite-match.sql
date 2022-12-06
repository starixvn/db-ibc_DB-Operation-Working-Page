
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20221027@Mira
Task : Event Picking New
DB: bodb_OWP	

Revisions:
	20201020@Mira: Save child matches from Infosite - [Redmine: #179302]
*/

-- EventPickingNoOfferMatch
CREATE TABLE [dbo].[EventPickingNoOfferMatch]
([Id]              INT IDENTITY(1, 1) NOT NULL, 
 [InfoSiteMatchId] INT NOT NULL, 
 [ChildMatchId]    INT
 CONSTRAINT [PK_EventPickingNoOfferMatch] PRIMARY KEY CLUSTERED ([Id] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [OWP_Data]
);
ALTER TABLE EventPickingNoOfferMatch
ADD CreatedDate DATETIME;

-- InfoSiteChildMatch
CREATE TABLE [dbo].[InfoSiteChildMatch]
([ChildMatchId]          INT IDENTITY(1, 1) NOT NULL, 
 [AdminSiteMatchId]      INT, 
 [ParentInfoSiteMatchId] INT NOT NULL, 
 [SubType]               INT NOT NULL, 
 [MinorBettypeId]        INT NOT NULL, 
 [OWPLeagueId]           INT NOT NULL, 
 [OWPHomeId]             INT NOT NULL, 
 [OWPAwayId]             INT NOT NULL, 
 [EventDateTime]         [DATETIME] NOT NULL, 
 [UpdatedTime]           [DATETIME] NOT NULL, 
 CONSTRAINT [PK_InfoSiteChildMatch] PRIMARY KEY CLUSTERED(ChildMatchId)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [OWP_Data]
)
ON [OWP_Data];
GO

-- Add more columns to the InfoSiteMatch  
ALTER TABLE InfoSiteMatch
ADD Remark2    NVARCHAR(2000), 
    HomeRemark NVARCHAR(2000), 
    AwayRemark NVARCHAR(2000), 
    IsTest     BIT, 
    TotalRound NVARCHAR(2000);
INSERT INTO [dbo].[Module]
([ModuleId], 
 [ModuleName]
)
       SELECT 16, 
              'EventPicking'
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[Module] WITH(NOLOCK)
           WHERE [ModuleId] = 16
       );
INSERT INTO [dbo].[ModuleObject]
([ModuleObjectId], 
 [ModuleObjectName], 
 [ModuleId]
)
       SELECT 44, 
              'EventPicking', 
              16
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[ModuleObject] WITH(NOLOCK)
           WHERE [ModuleObjectId] = 44
       );
IF NOT EXISTS
(
    SELECT 1
    FROM [LogAction]
    WHERE ActionId = 129
)
    INSERT INTO [dbo].[LogAction]
    ([ActionId], 
     [ModuleId], 
     [ModuleObjectId], 
     [ActionTypeId], 
     [ActionName], 
     [SPName], 
     [LogItems]
    )
    VALUES
    (129, 
     16, 
     44, 
     2, 
     N'OWP_EventPicking_InsertOrDeleteNoOfferMatch', 
     N'OWP_EventPicking_InsertOrDeleteNoOfferMatch', 
     N'<root><xml path="r/z"/><row item="InfoSiteMatchId" alias="imid"/><row item="ChildMatchId" alias="cmid"/><row item="IsNoOffer" alias="iof"/></root>'
    );