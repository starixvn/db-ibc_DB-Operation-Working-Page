CREATE TABLE [dbo].[AssignmentUploadingResult] (
    [SessionId]  VARCHAR (50)   NOT NULL,
    [RowNumber]  INT            NOT NULL,
    [RuleId]     SMALLINT       NOT NULL,
    [ResultType] SMALLINT       NOT NULL,
    [Message]    NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_AssignmentUploadingResult] PRIMARY KEY CLUSTERED ([SessionId] ASC, [RowNumber] ASC, [RuleId] ASC)
);



