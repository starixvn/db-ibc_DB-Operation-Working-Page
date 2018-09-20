CREATE TABLE [dbo].[LeagueRemarkSetting] (
    [LeagueId] INT            NOT NULL,
    [OptionId] INT            NOT NULL,
    [Remarks]  NVARCHAR (500) NULL,
    CONSTRAINT [PK_LeagueRemarkSetting] PRIMARY KEY CLUSTERED ([LeagueId] ASC, [OptionId] ASC) ON [PRIMARY]
);

