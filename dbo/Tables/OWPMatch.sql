CREATE TABLE [dbo].[OWPMatch] (
    [OWPMatchId]       INT            IDENTITY (1, 1) NOT NULL,
    [MatchNo]          VARCHAR (50)   CONSTRAINT [DF_OWPMatch_MatchNo] DEFAULT ('') NOT NULL,
    [EventDate]        DATETIME       NOT NULL,
    [KickOffTime]      TIME (7)       NOT NULL,
    [OWPLeagueId]      INT            NOT NULL,
    [OWPHomeId]        INT            NOT NULL,
    [OWPAwayId]        INT            NOT NULL,
    [MatchId]          INT            NULL,
    [OtherTime]        TIME (7)       NULL,
    [EventDateTime]    DATETIME       NULL,
    [InfositeMatchKey] NVARCHAR (400) NULL,
    [IsChecked]        BIT            NULL,
    CONSTRAINT [PK_OWPMatch] PRIMARY KEY CLUSTERED ([OWPMatchId] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_OWPLeagueId]
    ON [dbo].[OWPMatch]([OWPLeagueId] ASC)
    ON [OWP_Index];


GO
CREATE NONCLUSTERED INDEX [IX_MatchNo]
    ON [dbo].[OWPMatch]([MatchNo] ASC)
    INCLUDE([OWPHomeId], [OWPAwayId])
    ON [OWP_Index];


GO
CREATE NONCLUSTERED INDEX [IX_MatchId]
    ON [dbo].[OWPMatch]([MatchId] ASC)
    INCLUDE([EventDate], [KickOffTime])
    ON [OWP_Index];

