CREATE TABLE [dbo].[OWPLeague] (
    [OWPLeagueId]   INT             IDENTITY (1, 1) NOT NULL,
    [OWPLeagueName] NVARCHAR (2000) NOT NULL,
    [CategoryId]    SMALLINT        NULL,
    [IsActive]      BIT             NULL,
    [IsBlackList]   BIT             NULL,
    CONSTRAINT [PK_OWPLeague] PRIMARY KEY CLUSTERED ([OWPLeagueId] ASC)
);

