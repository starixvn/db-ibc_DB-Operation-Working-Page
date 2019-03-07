CREATE TABLE [dbo].[MatchOfferDetail] (
    [OWPMatchId]   INT NOT NULL,
    [MatchOfferId] INT NOT NULL,
    CONSTRAINT [PK_MatchOfferDetail] PRIMARY KEY CLUSTERED ([OWPMatchId] ASC, [MatchOfferId] ASC)
);



