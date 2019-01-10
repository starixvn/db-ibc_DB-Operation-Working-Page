CREATE TABLE [dbo].[RefResource] (
    [RefName]    VARCHAR (30)   NOT NULL,
    [ResourceId] INT            NOT NULL,
    [Value]      NVARCHAR (200) NOT NULL,
    CONSTRAINT [PK_RefResource] PRIMARY KEY CLUSTERED ([RefName] ASC, [ResourceId] ASC)
);






GO


