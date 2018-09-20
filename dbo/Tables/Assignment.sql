CREATE TABLE [dbo].[Assignment] (
    [UserId]         INT      NOT NULL,
    [OWPMatchId]     INT      NOT NULL,
    [Bettype]        INT      NOT NULL,
    [AssignmentType] SMALLINT NOT NULL,
    [IsLive]         BIT      NOT NULL,
    CONSTRAINT [PK_Assignment] PRIMARY KEY CLUSTERED ([UserId] ASC, [OWPMatchId] ASC, [Bettype] ASC, [AssignmentType] ASC, [IsLive] ASC)
);

