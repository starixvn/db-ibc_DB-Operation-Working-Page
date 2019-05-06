CREATE TABLE [dbo].[MatchInfo] (
    [OWPMatchId]            INT             NOT NULL,
    [Channel]               NVARCHAR (100)  NULL,
    [WB]                    NVARCHAR (100)  NULL,
    [Phone]                 NVARCHAR (50)   NULL,
    [ExtraTimeRemark]       NVARCHAR (100)  NULL,
    [Venue]                 NVARCHAR (100)  NULL,
    [LocalTV]               NVARCHAR (100)  NULL,
    [LiveTV]                NVARCHAR (100)  NULL,
    [IsSelectedUpdatedDate] DATETIME        NULL,
    [IsSelected]            BIT             CONSTRAINT [DF_MatchInfo_IsSelected] DEFAULT ((0)) NOT NULL,
    [SelectedBy]            INT             NULL,
    [IsSoloMatch]           BIT             CONSTRAINT [DF_MatchInfo_IsSoloMatch] DEFAULT ((0)) NOT NULL,
    [Round]                 NVARCHAR (2000) NULL,
    [Division]              NVARCHAR (2000) NULL,
    [Remark]                NVARCHAR (2000) NULL,
    [Website1]              NVARCHAR (1000) NULL,
    [Website2]              NVARCHAR (1000) NULL,
    [Website3]              NVARCHAR (1000) NULL,
    [Website4]              NVARCHAR (1000) NULL,
    [MatchStatus]           VARCHAR (15)    CONSTRAINT [DF_MatchInfo_MatchStatus] DEFAULT ('Live') NOT NULL,
    [NoOfHDPId]             INT             NULL,
    CONSTRAINT [PK_MatchInfo] PRIMARY KEY CLUSTERED ([OWPMatchId] ASC)
);
















GO
CREATE NONCLUSTERED INDEX [IX_MatchInfo_IsSelected]
    ON [dbo].[MatchInfo]([IsSelected] DESC)
    INCLUDE([OWPMatchId])
    ON [OWP_Index];

