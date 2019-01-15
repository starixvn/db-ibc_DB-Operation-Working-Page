CREATE TABLE [dbo].[AutoAssignmentRequest] (
    [RequestId]   VARCHAR (50) NOT NULL,
    [EventDate]   DATE         NOT NULL,
    [Status]      INT          NOT NULL,
    [CreatedDate] DATETIME     CONSTRAINT [DF_AutoAssignmentRequest_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatorId]   INT          NOT NULL,
    CONSTRAINT [PK_AutoAssignmentRequest] PRIMARY KEY CLUSTERED ([RequestId] ASC)
);






GO



GO



GO
CREATE NONCLUSTERED INDEX [IX_AutoAssignmentRequest_CreatedDate]
    ON [dbo].[AutoAssignmentRequest]([CreatedDate] DESC)
    ON [OWP_Index];

