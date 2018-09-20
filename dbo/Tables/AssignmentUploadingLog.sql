CREATE TABLE [dbo].[AssignmentUploadingLog] (
    [SessionId]      NVARCHAR (100) NOT NULL,
    [UserId]         INT            NULL,
    [TotalRowResult] INT            NULL,
    [CreatedDate]    DATETIME       NULL,
    [StartDate]      DATETIME       NULL,
    [EndDate]        DATETIME       NULL,
    [Status]         INT            NULL,
    [LogMessage]     NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_AssignmentUploadingLog] PRIMARY KEY CLUSTERED ([SessionId] ASC) ON [PRIMARY]
) TEXTIMAGE_ON [PRIMARY];

