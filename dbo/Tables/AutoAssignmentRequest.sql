CREATE TABLE [dbo].[AutoAssignmentRequest] (
    [RequestId]    VARCHAR (50) NOT NULL,
    [EventDate]    DATE         NOT NULL,
    [Status]       INT          NOT NULL,
    [CreatedDate]  DATETIME     CONSTRAINT [DF_AutoAssignmentRequest_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatorId]    INT          NOT NULL,
    [Id]           INT          IDENTITY (1, 1) NOT NULL,
    [RequestDate]  DATETIME     NULL,
    [ResponseDate] DATETIME     NULL,
    CONSTRAINT [PK_AutoAssignmentRequest] PRIMARY KEY CLUSTERED ([RequestId] ASC)
);








GO



GO



GO


