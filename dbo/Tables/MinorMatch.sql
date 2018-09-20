CREATE TABLE [dbo].[MinorMatch] (
    [RelationshipId] INT IDENTITY (1, 1) NOT NULL,
    [MinorMatchId]   INT NOT NULL,
    [ParentMatchId]  INT NOT NULL,
    [MinorBettypeId] INT NOT NULL,
    [IsRepresented]  BIT NOT NULL,
    [GroupId]        INT NULL
) ON [PRIMARY];

