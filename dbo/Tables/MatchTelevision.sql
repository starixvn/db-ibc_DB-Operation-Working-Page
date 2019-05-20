CREATE TABLE [dbo].[MatchTelevision] (
    [OWPMatchId] INT NOT NULL,
    [TVId]       INT NOT NULL,
    CONSTRAINT [PK_MatchTelevision] PRIMARY KEY CLUSTERED ([OWPMatchId] ASC, [TVId] ASC)
);

