CREATE TABLE [dbo].[MatchNote] (
    [MatchNoteId] INT             IDENTITY (1, 1) NOT NULL,
    [OWPMatchId]  INT             NOT NULL,
    [CreatedDate] DATETIME        NOT NULL,
    [CreatedBy]   INT             NOT NULL,
    [Note]        NVARCHAR (2000) NOT NULL,
    CONSTRAINT [PK_MatchNote] PRIMARY KEY CLUSTERED ([MatchNoteId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [CIX_OWPMatchId]
    ON [dbo].[MatchNote]([OWPMatchId] ASC) WITH (FILLFACTOR = 100)
    ON [OWP_Index];

