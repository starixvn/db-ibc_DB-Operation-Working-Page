CREATE TABLE [dbo].[MinorBettype] (
    [MinorBettypeId]     INT            IDENTITY (-1, -1) NOT NULL,
    [MinorBettypeName]   NVARCHAR (100) NOT NULL,
    [ParentBettypeId]    INT            NULL,
    [InheritedBettypeId] INT            NULL,
    [Alias]              VARCHAR (10)   NULL,
    [IsActive]           BIT            NULL,
    [IsMinorBettype]     BIT            NULL,
    [Order]              INT            NULL,
    CONSTRAINT [PK_MinorBettype] PRIMARY KEY CLUSTERED ([MinorBettypeId] DESC)
);








GO
CREATE NONCLUSTERED INDEX [IX_MinorBettype_ParentInherited]
    ON [dbo].[MinorBettype]([ParentBettypeId] ASC, [InheritedBettypeId] ASC)
    INCLUDE([MinorBettypeName], [IsActive])
    ON [OWP_Index];

