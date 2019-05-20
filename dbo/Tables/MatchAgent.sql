CREATE TABLE [dbo].[MatchAgent] (
    [OWPMatchId] INT NOT NULL,
    [AgentId]    INT NOT NULL,
    CONSTRAINT [PK_MatchAgent] PRIMARY KEY CLUSTERED ([OWPMatchId] ASC, [AgentId] ASC)
);

