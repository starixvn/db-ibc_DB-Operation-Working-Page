CREATE TABLE [dbo].[RefResource] (
    [RefResourceId] INT            IDENTITY (1, 1) NOT NULL,
    [RefName]       VARCHAR (30)   NOT NULL,
    [ResourceId]    SMALLINT       NOT NULL,
    [Value]         NVARCHAR (200) NULL,
    CONSTRAINT [PK_RefResource] PRIMARY KEY CLUSTERED ([RefName] ASC, [ResourceId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_RefResourceId]
    ON [dbo].[RefResource]([RefResourceId] ASC)
    ON [OWP_Index];

