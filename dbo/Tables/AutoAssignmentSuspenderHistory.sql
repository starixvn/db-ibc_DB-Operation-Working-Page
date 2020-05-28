CREATE TABLE [dbo].[AutoAssignmentSuspenderHistory] (
    [UserId]  INT      NOT NULL,
    [InTime]  DATETIME NOT NULL,
    [OutTime] DATETIME NOT NULL,
    PRIMARY KEY CLUSTERED ([UserId] ASC, [InTime] ASC)
);

