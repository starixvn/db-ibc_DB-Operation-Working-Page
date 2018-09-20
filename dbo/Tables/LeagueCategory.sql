CREATE TABLE [dbo].[LeagueCategory] (
    [LeagueId]   INT      NOT NULL,
    [CategoryId] SMALLINT NULL,
    CONSTRAINT [PK_LeagueCategory] PRIMARY KEY CLUSTERED ([LeagueId] ASC)
);

