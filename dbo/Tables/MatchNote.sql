CREATE TABLE [dbo].[MatchNote] (
    [MatchNoteId] INT             IDENTITY (1, 1) NOT NULL,
    [OWPMatchId]  INT             NOT NULL,
    [CreatedDate] DATETIME        CONSTRAINT [DF_MatchNote_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]   INT             NOT NULL,
    [Note]        NVARCHAR (4000) NOT NULL,
    CONSTRAINT [PK_MatchNote] PRIMARY KEY NONCLUSTERED ([MatchNoteId] ASC) ON [OWP_Index]
);






GO
CREATE CLUSTERED INDEX [CIX_MatchNote]
    ON [dbo].[MatchNote]([OWPMatchId] ASC);

