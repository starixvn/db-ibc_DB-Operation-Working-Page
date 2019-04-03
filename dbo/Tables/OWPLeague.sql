CREATE TABLE [dbo].[OWPLeague] (
    [OWPLeagueId]   INT            IDENTITY (1, 1) NOT NULL,
    [OWPLeagueName] NVARCHAR (500) NOT NULL,
    [CategoryId]    SMALLINT       NULL,
    [IsActive]      BIT            CONSTRAINT [DF_OWPLeague_IsActive] DEFAULT ((1)) NOT NULL,
    [IsBlackList]   BIT            NULL,
    CONSTRAINT [PK_OWPLeague] PRIMARY KEY CLUSTERED ([OWPLeagueId] ASC)
);










GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_OWPLeague_OWPLeagueName]
    ON [dbo].[OWPLeague]([OWPLeagueName] ASC)
    ON [OWP_Index];

