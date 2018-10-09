CREATE TABLE [dbo].[AssignmentUploadingOtherTrader] (
    [AssignmentId] INT            IDENTITY (1, 1) NOT NULL,
    [SessionId]    VARCHAR (50)   NOT NULL,
    [RowNumber]    INT            NOT NULL,
    [Bettype]      INT            NOT NULL,
    [Trader]       NVARCHAR (200) CONSTRAINT [DF_AssignmentUploadingOtherTrader_Trader] DEFAULT ('') NOT NULL,
    [Note]         NVARCHAR (200) CONSTRAINT [DF_AssignmentUploadingOtherTrader_Note] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_AssignmentUploadingOtherTrader] PRIMARY KEY CLUSTERED ([AssignmentId] ASC)
);

