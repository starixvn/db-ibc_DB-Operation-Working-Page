CREATE TABLE [dbo].[AutoAssignmentResult] (
    [RequestId]  VARCHAR (50) NOT NULL,
    [OWPMatchId] INT          NOT NULL,
    [Bettype]    INT          NOT NULL,
    [UserId]     INT          NULL,
    [StatusCode] INT          NULL,
    CONSTRAINT [PK_AutoAssignmentResult] PRIMARY KEY CLUSTERED ([RequestId] ASC, [OWPMatchId] ASC, [Bettype] ASC)
);



