CREATE TABLE [dbo].[MatchPickingQueue] (
    [KeyId]  INT            NOT NULL,
    [SQLcmd] NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_MatchPickingQueue] PRIMARY KEY CLUSTERED ([KeyId] ASC)
);

