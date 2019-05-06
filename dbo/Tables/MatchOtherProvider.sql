CREATE TABLE [dbo].[MatchOtherProvider] (
    [OWPMatchId]      INT NOT NULL,
    [OtherProviderId] INT NOT NULL,
    CONSTRAINT [PK_MatchOtherProvider] PRIMARY KEY CLUSTERED ([OWPMatchId] ASC, [OtherProviderId] ASC)
);

