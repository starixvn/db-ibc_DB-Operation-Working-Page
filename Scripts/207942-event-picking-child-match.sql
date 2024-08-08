
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20240808@Mira
Task : Event Picking Child Match
DB: bodb_OWP

Revisions:
	20240808@Mira: create new table for event picking child match - [Redmine: #207942]
*/

CREATE TABLE [dbo].[EventPickingChildMatch]
([Id]             [INT] IDENTITY(1, 1) NOT NULL, 
 [ParentId]       [INT] NOT NULL, 
 [MinorBettypeId] [INT] NOT NULL, 
 [MaxbetHDP]      [MONEY] NULL, 
 [SpreadHDP]      [MONEY] NULL, 
 [SpreadOU]       [MONEY] NULL, 
 [NoOfHDP]        [MONEY] NULL, 
 CONSTRAINT [PK_EventPickingChildMatch] PRIMARY KEY CLUSTERED([Id] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [OWP_Data]
)
ON [OWP_Data];
CREATE NONCLUSTERED INDEX IX_EventPickingChildMatch_ParentId ON [dbo].[EventPickingChildMatch]([ParentId]) ON [OWP_Data];
GO