CREATE TABLE [dbo].[AutoAssignmentBettype] (
    [MinorBettypeId]      INT NOT NULL,
    [SchedulingBettypeId] INT NOT NULL,
    CONSTRAINT [PK_AutoAssignmentBettype] PRIMARY KEY CLUSTERED ([MinorBettypeId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_AutoAssignmentBettype_SchedulingBettypeId]
    ON [dbo].[AutoAssignmentBettype]([SchedulingBettypeId] ASC)
    ON [OWP_Index];

