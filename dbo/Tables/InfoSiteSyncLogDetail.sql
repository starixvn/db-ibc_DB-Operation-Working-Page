CREATE TABLE [dbo].[InfoSiteSyncLogDetail] (
    [LogId]           INT NOT NULL,
    [OWPMatchId]      INT NOT NULL,
    [InfoSiteMatchId] INT NOT NULL,
    CONSTRAINT [PK_InfoSiteSyncLogDetail] PRIMARY KEY CLUSTERED ([LogId] ASC, [OWPMatchId] ASC)
);

