CREATE TABLE [dbo].[MinorBettype] (
    [MinorBettypeId]     INT            IDENTITY (-1, -1) NOT NULL,
    [MinorBettypeName]   NVARCHAR (100) NOT NULL,
    [ParentBettypeId]    INT            NULL,
    [InheritedBettypeId] INT            NULL,
    [Alias]              VARCHAR (10)   NULL,
    [IsActive]           BIT            NULL,
    [IsMinorBettype]     BIT            NULL,
    [LinkBettypeId]      INT            NULL
) ON [PRIMARY];

