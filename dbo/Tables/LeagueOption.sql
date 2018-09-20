CREATE TABLE [dbo].[LeagueOption] (
    [OptionId]   SMALLINT       IDENTITY (1, 1) NOT NULL,
    [CategoryId] TINYINT        NULL,
    [Name]       NVARCHAR (100) NOT NULL,
    [Value]      INT            NOT NULL,
    CONSTRAINT [PK_LeagueOption] PRIMARY KEY CLUSTERED ([OptionId] ASC) ON [PRIMARY]
);

