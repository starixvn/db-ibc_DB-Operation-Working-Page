CREATE TABLE [dbo].[AutoAssignmentRequest] (
    [RequestId]   VARCHAR (50) NOT NULL,
    [EventDate]   DATE         NOT NULL,
    [Status]      INT          NOT NULL,
    [CreatedDate] DATETIME     CONSTRAINT [DF_AutoAssignmentRequest_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatorId]   INT          NOT NULL,
    CONSTRAINT [PK_AutoAssignmentRequest] PRIMARY KEY CLUSTERED ([RequestId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_AutoAssignmentRequest_CreatorId]
    ON [dbo].[AutoAssignmentRequest]([CreatorId] ASC)
    ON [OWP_Index];


GO
CREATE NONCLUSTERED INDEX [IX_AutoAssignmentRequest_Status]
    ON [dbo].[AutoAssignmentRequest]([Status] ASC)
    ON [OWP_Index];

