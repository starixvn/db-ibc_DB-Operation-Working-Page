CREATE TABLE [dbo].[MinorMatch] (
    [RelationshipId] INT IDENTITY (1, 1) NOT NULL,
    [MinorMatchId]   INT NOT NULL,
    [ParentMatchId]  INT NOT NULL,
    [MinorBettypeId] INT NOT NULL,
    [IsRepresented]  BIT NOT NULL,
    [GroupId]        INT NULL,
    CONSTRAINT [PK_MinorMatch] PRIMARY KEY NONCLUSTERED ([RelationshipId] ASC)
);






GO
CREATE CLUSTERED INDEX [CIX_MinorMatch]
    ON [dbo].[MinorMatch]([MinorMatchId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MinorMatch_ParentMatchId]
    ON [dbo].[MinorMatch]([ParentMatchId] ASC)
    ON [OWP_Index];

