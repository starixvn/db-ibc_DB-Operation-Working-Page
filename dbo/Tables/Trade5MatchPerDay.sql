CREATE TABLE [dbo].[Trade5MatchPerDay] (
    [Date]   DATE NOT NULL,
    [UserId] INT  NOT NULL,
    CONSTRAINT [PK_Trade5MatchPerDay] PRIMARY KEY CLUSTERED ([Date] ASC, [UserId] ASC) ON [PRIMARY]
);

