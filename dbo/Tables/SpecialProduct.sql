CREATE TABLE [dbo].[SpecialProduct] (
    [ProductId]         INT             IDENTITY (1, 1) NOT NULL,
    [Maxbet_FTHDP]      MONEY           NULL,
    [Maxbet_NoOfCorner] MONEY           NULL,
    [Spread_NoOfCorner] MONEY           NULL,
    [Maxbet_NextCorner] MONEY           NULL,
    [Maxbet_10_15Mins]  MONEY           NULL,
    [Spread_10_15Mins]  MONEY           NULL,
    [Maxbet_TB]         MONEY           NULL,
    [Spread_TB]         MONEY           NULL,
    [Maxbet_NextTB]     MONEY           NULL,
    [Spread_NextTB]     MONEY           NULL,
    [Maxbet_PS]         MONEY           NULL,
    [Spread_PS]         MONEY           NULL,
    [Maxbet_Winner]     MONEY           NULL,
    [Spread_Winner]     MONEY           NULL,
    [Remark]            NVARCHAR (2000) NULL,
    [LastUpdate]        VARCHAR (255)   NULL,
    [Type]              VARCHAR (10)    NULL,
    PRIMARY KEY CLUSTERED ([ProductId] ASC)
);



