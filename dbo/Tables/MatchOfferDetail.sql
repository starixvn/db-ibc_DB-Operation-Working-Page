CREATE TABLE [dbo].[MatchOfferDetail] (
    [OWPMatchId] INT NOT NULL,
    [MatchOffer] INT NOT NULL,
    CONSTRAINT [PK_MatchOfferDetail] PRIMARY KEY CLUSTERED ([OWPMatchId] ASC, [MatchOffer] ASC)
);

