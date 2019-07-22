CREATE TABLE [dbo].[AssignmentUploadingLog] (
    [SessionId]      VARCHAR (50)  NOT NULL,
    [UserId]         INT           NOT NULL,
    [TotalRowResult] INT           NOT NULL,
    [CreatedDate]    DATETIME      CONSTRAINT [DF_AssignmentUploadingLog_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [StartDate]      DATETIME      NULL,
    [EndDate]        DATETIME      NULL,
    [Status]         TINYINT       NOT NULL,
    [LogMessage]     VARCHAR (MAX) CONSTRAINT [DF_AssignmentUploadingLog_LogMessage] DEFAULT ('') NOT NULL,
    [TotalRowUpload] INT           CONSTRAINT [DF_AssignmentUploadingLog_TotalRowUpload] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AssignmentUploadingLog] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);








GO
CREATE NONCLUSTERED INDEX [IX_AssginmentUploadingLog]
    ON [dbo].[AssignmentUploadingLog]([CreatedDate] ASC)
    ON [OWP_Index];

