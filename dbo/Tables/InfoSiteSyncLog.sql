CREATE TABLE [dbo].[InfoSiteSyncLog] (
    [LogId]     INT      IDENTITY (1, 1) NOT NULL,
    [StartTime] DATETIME CONSTRAINT [DF_InfoSiteSyncLog_StartTime] DEFAULT (getdate()) NOT NULL,
    [EndTime]   DATETIME NULL,
    CONSTRAINT [PK_InfoSiteSyncLog] PRIMARY KEY CLUSTERED ([LogId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_InfoSiteSyncLog]
    ON [dbo].[InfoSiteSyncLog]([StartTime] ASC)
    ON [OWP_Index];

