CREATE TABLE [dbo].[MatchNoteUser] (
    [MatchNoteId] INT NOT NULL,
    [UserId]      INT NOT NULL,
    [IsViewed]    BIT NOT NULL,
    CONSTRAINT [PK_MatchNoteUser] PRIMARY KEY CLUSTERED ([MatchNoteId] ASC, [UserId] ASC)
);

